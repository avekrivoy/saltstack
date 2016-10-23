# State recursively retrieves data from /etc/passwd
# using user.getent module and removes public ssh-key in
# pillar's 'key_revoked' from all system's user homedirs.

{% for userattr in salt['user.getent']() %}

  {% set username = userattr['name'] %}
  {% set homedir = userattr['home'] %}
  {% set ssh_key = pillar['key_revoked'] %}

    remove_key_from_{{ username }}_dir:
        ssh_auth.absent:
            - name: {{ ssh_key }}
            - config: {{ homedir }}/.ssh/authorized_keys
            - user: {{ username }}

{% endfor %}

