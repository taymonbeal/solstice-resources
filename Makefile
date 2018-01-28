DIRS=$(patsubst %/Makefile,%,$(wildcard */Makefile))

allindex:
	mkdir gen
	for i in ${DIRS}; do (cd $$i && mkdir gen && make all); done

index.html: allindex
	./scripts/create-main-index.sh > index.html

all: index.html

clean:
	rm -rf index.html gen */gen
