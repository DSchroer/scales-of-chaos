play:
	love src

build: linux windows

linux: lovefile
	-mkdir -p builds/linux
	cd src && zip -r ../scales-of-chaos.love *
	cat /usr/bin/love scales-of-chaos.love > builds/linux/scales-of-chaos
	chmod +x builds/linux/scales-of-chaos

windows: lovefile
	-mkdir -p builds/windows	
	-rm -r .tmp
	-mkdir .tmp
	cd .tmp && wget https://github.com/love2d/love/releases/download/11.4/love-11.4-win64.zip
	cd .tmp && unzip love-11.4-win64.zip
	mv .tmp/love-11.4-win64/*.dll builds/windows/
	cat .tmp/love-11.4-win64/love.exe scales-of-chaos.love > builds/windows/scales-of-chaos.exe

lovefile:
	cd src && zip -r ../scales-of-chaos.love *
