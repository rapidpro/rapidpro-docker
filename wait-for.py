import click
import re
import time
import docker
from docker.errors import NotFound


def wait_for(container, pattern, timeout=60, sleep=1, verbose=False):
    time_spent = 0
    while True:
        logs = container.logs()
        if re.findall(pattern, logs.decode('utf-8')):
            break
        time.sleep(sleep)
        time_spent += sleep
        if time_spent > timeout:
            if verbose:
                print(logs)
            raise click.ClickException(
                'Timeout of %s reached for %s' % (timeout, logs))
    return True


@click.command()
@click.option("--name", type=click.STRING,
              help="Which container to wait for")
@click.option("--timeout", type=click.INT,
              help="How long to wait for.",
              default=60)
@click.option("--sleep", type=click.INT,
              help="How long to sleep for in between checking",
              default=1)
@click.option("--verbose/--no-verbose",
              help="Log the stdout captured on timeout.",
              default=False)
@click.argument("find", type=click.STRING)
def cmd(name, timeout, sleep, verbose, find):
    client = docker.from_env()
    try:
        container = client.containers.get(name)
    except NotFound:
        raise click.ClickException('Container %s does not exist.' % (
            name,))

    if find:
        return wait_for(container, find, timeout=timeout, verbose=verbose)


if __name__ == '__main__':
    cmd()
