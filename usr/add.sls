# State will create users with 'users_active' True boolean pillar value.
# User data is kept in 'users' section. You can add new users there.
# Note that full names in 'users', 'users_active', 'users_revoked' should match:
# users:
#   bob_bannister:
#    ...
#
# users_active:
#   bob_bannister:
#    ...

{% for user, user_enabled in salt['pillar.get']('users_active', {}).iteritems() %}

  {% set username = pillar['users'][user]['username'] %}
  {% set sudo = pillar['users'][user]['sudo'] %}
  {% set ssh_key = pillar['users'][user]['ssh-key'] %}

  {% if user_enabled == True %}

    {{ user }}_login:
        user.present:
            - name: {{ username }}
            - shell: /bin/bash
            - home: /home/{{ username }}

    {{ username }}_ssh_auth:
        ssh_auth.present:
            - user: {{ username }}
            - name: {{ ssh_key }}
            - comment: {{ user }}

  {% endif %}

  {% if sudo == True and user_enabled == True %}

    /etc/sudoers.d/{{ username }}_sudo:
        file.managed:
            - create: True
            - user: root
            - group: root
            - mode: 0440
            - contents: |
                {{ username }} ALL=(ALL) NOPASSWD: ALL

  {% endif %}

{% endfor %}
