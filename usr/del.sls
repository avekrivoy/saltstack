# State removes user defined in 'users_revoked' pillar section with his homedir.
# To completely remove user's public key from server use usr.rmkey state. 
# NOTE: There is a bug in Debian 8.1 which prevents deleting account while user logged in

{% for user, user_delete in salt['pillar.get']('users_revoked', {}).iteritems() %}

  {% set username = pillar['users'][user]['username'] %}
  {% set ssh_key = pillar['users'][user]['ssh-key'] %}

    {% if user_delete == True %}

      {{ user }}_key_del:
          ssh_auth.absent:
              - name: {{ ssh_key }}
              - user: {{ username }}
              - config: '/home/{{ username }}/.ssh/authorized_keys'

      {{ username }}_force_logout:
          cmd.run:
              - name: 'pkill -KILL -u {{ username }}'

      {{ user }}_del:
          user.absent:
              - name: {{ username }}
              - force: True
              - purge: True

      remove_{{ username }}_from_sudoers:
          file.absent:
            - name: /etc/sudoers.d/{{ username }}_sudo

    {% endif %}

{% endfor %}

