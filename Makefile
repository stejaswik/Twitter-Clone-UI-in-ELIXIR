all:
	mix deps.get
	mix deps.compile
	cd assets && npm install
	cd ..

start:
	mix phx.server

test:
	mix test

clean:
	mix clean
