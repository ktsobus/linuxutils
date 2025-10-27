#!/bin/bash

#!/usr/bin/env bash

# SSH-Agent starten, falls nicht aktiv
if ! pgrep -u "$USER" ssh-agent >/dev/null; then
  eval "$(ssh-agent -s)"
else
  export SSH_AGENT_PID=$(pgrep ssh-agent)
  export SSH_AUTH_SOCK=$(find /tmp/ssh-* -name "agent.*" -print 2>/dev/null | head -n1)
fi

# Temporären Askpass-Helfer erstellen
create_askpass() {
  local pass="$1"
  local script
  umask 077 # Nur der aktuelle Benutzer darf die Datei lesen
  script=$(mktemp)
  cat >"$script" <<EOF
#!/usr/bin/env bash
echo '${pass//\'/\'\\\'\'}'
EOF
  chmod 700 "$script" # explizit, obwohl umask meist schon reicht
  echo "$script"
}

# Prüfen, ob Key passwortgeschützt ist (ohne Passwortabfrage!)
is_encrypted_key() {
  local keyfile="$1"
  ssh-keygen -y -P "" -f "$keyfile" >/dev/null 2>&1
  [[ $? -ne 0 ]] # Rückgabe 0 = unverschlüsselt, ≠ 0 = passwortgeschützt
}

# Schlüssel in zwei Gruppen aufteilen
unencrypted_keys=()
encrypted_keys=()

for key in ~/.ssh/id_*; do
  if [[ -f "$key" && "$key" != *.pub ]]; then
    fingerprint=$(ssh-keygen -lf "$key" | awk '{print $2}' 2>/dev/null)
    if ssh-add -l 2>/dev/null | grep -q "$fingerprint"; then
      continue # bereits im Agent
    fi

    if is_encrypted_key "$key"; then
      encrypted_keys+=("$key")
    else
      unencrypted_keys+=("$key")
    fi
  fi
done

#echo "En: $encrypted_keys"
#echo "Un: $unencrypted_keys"

# Passwortlose Schlüssel direkt laden
if [ ${#unencrypted_keys[@]} -gt 0 ]; then
  ssh-add "${unencrypted_keys[@]}" >/dev/null 2>&1
fi

# Wenn keine verschlüsselten Schlüssel, Script beenden
if [ ! ${#encrypted_keys[@]} -eq 0 ]; then

  # Erstes Passwort für alle verschlüsselten Schlüssel abfragen
  echo -n "Passwort für ${#encrypted_keys[@]} Schlüssel: "
  read -s common_pass
  echo

  askpass_script=$(create_askpass "$common_pass")

  # Liste der Keys, die mit diesem Passwort nicht geladen wurden
  failed_keys=()

  for key in "${encrypted_keys[@]}"; do
    (
      export SSH_ASKPASS="$askpass_script"
      export SSH_ASKPASS_REQUIRE=force
      DISPLAY=: timeout 2 ssh-add "$key" >/dev/null 2>&1
    )

    fingerprint=$(ssh-keygen -lf "$key" 2>/dev/null | awk '{print $2}')
    if ! ssh-add -l 2>/dev/null | grep -q "$fingerprint"; then
      failed_keys+=("$key")
    fi
  done

  rm -f "$askpass_script"

  # Nun für jeden nicht geladenen Key einzeln Passwort abfragen
  for key in "${failed_keys[@]}"; do
    while true; do
      echo -n "Passwort für Schlüssel $key: "
      read -s single_pass
      echo

      askpass_script=$(create_askpass "$single_pass")

      (
        export SSH_ASKPASS="$askpass_script"
        export SSH_ASKPASS_REQUIRE=force
        DISPLAY=: timeout 2 ssh-add "$key" >/dev/null 2>&1
      )

      rm -f "$askpass_script"

      fingerprint=$(ssh-keygen -lf "$key" 2>/dev/null | awk '{print $2}')
      if ssh-add -l 2>/dev/null | grep -q "$fingerprint"; then
        echo "Schlüssel $key erfolgreich geladen."
        break
      else
        echo "Falsches Passwort für $key, bitte erneut versuchen."
      fi
    done
  done
fi
