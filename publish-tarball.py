#!/usr/bin/env python
import argparse
import os
import ConfigParser

from pygithub3.services.repos import Downloads

config = ConfigParser.ConfigParser()
config.read(os.path.expanduser('~/.kickstandproject.cfg'))

login = config.get('github', 'login')
password = config.get('github', 'password')

auth = dict(login=login, password=password)

parser = argparse.ArgumentParser()
parser.add_argument('filename')
parser.add_argument('--user')
parser.add_argument('--repo')
args = parser.parse_args()

filesize = os.path.getsize(args.filename)

downloads_service = Downloads(**auth)

download = downloads_service.create(
    dict(name=args.filename, size=filesize),
    user=args.user, repo=args.repo)

x = download.upload(args.filename)
print x
