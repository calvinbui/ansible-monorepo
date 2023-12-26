from ansible.errors import AnsibleError


def argon2(passwd):
    try:
        from passlib.hash import argon2
    except Exception as e:
        raise AnsibleError("to use this filter, you need passlib pip package installed")

    digest = argon2.using(
        type="ID",
        memory_cost=65536,
        time_cost=3,
        parallelism=4,
    ).hash(passwd)

    return digest


class FilterModule(object):
    def filters(self):
        return {
            "argon2": argon2,
        }
