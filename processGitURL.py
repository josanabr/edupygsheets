#!/usr/bin/env python
# -*- coding: latin-1 -*-
#
# Este script puede recibir como argumentos
# -u: denota usuario
# -r: denota repositorio
#
# Dado un URL de github (e.g. https://github.com/josanabr/demo.git) y si
# se le pasa el flag '-u' devuelve el usuario 'josanabr'.
# Si se le pasa el flag '-r' devuelve el repositorio 'demo'
#
# Este script da los elementos para consultar si un repositorio en git
# existe o no
# - http://stackoverflow.com/questions/23914896/check-that-git-repository-exists

import sys
import getopt
#from urllib.parse import urlparse
from urlparse import urlparse

# Para convertir de list a String 
# - http://stackoverflow.com/questions/5618878/how-to-convert-list-to-string
# Para procesar argumentos
# - https://www.tutorialspoint.com/python/python_command_line_arguments.htm

def main(argv):
	opts, args = getopt.getopt(argv,"r:u:")
	for opt, arg in opts:
		parsed = urlparse(arg)
		if opt == '-r':
			print ''.join((parsed.path.split("/")[-1:]))
			sys.exit(0)
		elif opt == '-u':
			print ''.join(parsed.path.split("/")[-2:-1])
			sys.exit(0)

if __name__ == "__main__":
	main(sys.argv[1:])
