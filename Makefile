build:
	idris --codegen javascript -o out.js CustomElement.idr

dev:
	idris CustomElement.idr
