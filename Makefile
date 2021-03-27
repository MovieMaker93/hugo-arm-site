.PHONY: all commit push

MEX ?= "default Commit"

all: commit push

commit:
	git commit -m $(MEX)
push:
	git push origin master
