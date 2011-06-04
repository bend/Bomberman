#compiles the project
all:
	ozc -c utils.oz man.oz grid.oz gui.oz score.oz ia.oz
	ozc -x mainExec.oz
