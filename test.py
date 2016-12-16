#!/usr/bin/env python
import requests
import unittest
import sys

DEFAULT_TIMEOUT = 15  # Seconds


class TestRapidProImage(unittest.TestCase):
    def test_is_it_running(self):
        """
        When the container is run with no arguments, rapidpro should start.
        """
        response = requests.get('http://localhost:8000/')
        response.raise_for_status()


if __name__ == '__main__':
    unittest.main(argv=sys.argv)
