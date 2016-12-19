import click
import re
import time
import subprocess


def call(cmd, timeout=60):
    return subprocess.run(
        cmd,
        timeout=timeout,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        universal_newlines=True)


def wait_for(cmd, pattern, timeout=60, sleep=1, verbose=False):
    process = call(cmd, timeout=timeout)
    time_spent = 0
    while not re.findall(pattern, process.stdout):
        time.sleep(sleep)
        time_spent += sleep
        if time_spent > timeout:
            if verbose:
                print(process.stdout)
            raise click.ClickException(
                'Timeout of %s reached for %s' % (timeout, ' '.join(cmd)))
    return True


@click.command()
@click.option("--service", type=click.STRING,
              help="Which service to wait for")
@click.option("--find", type=click.STRING,
              help="What regex to find in the services logs (does re.findall)")
@click.option("--timeout", type=click.INT,
              help="How long to wait for.",
              default=60)
@click.option("--sleep", type=click.INT,
              help="How long to sleep for in between checking",
              default=1)
@click.option("--verbose/--no-verbose",
              help="Log the stdout captured on timeout.",
              default=False)
def cmd(service, find, timeout, sleep, verbose):
    if wait_for(["docker-compose", "ps", service], r"Up",
                timeout=timeout, verbose=verbose):
        if find:
            return wait_for(
                ["docker-compose", "logs", "--no-color", service],
                find, timeout=timeout, verbose=verbose)


if __name__ == '__main__':
    cmd()
