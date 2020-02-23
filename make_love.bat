:: Needs a Java Development Kit on the PATH
mkdir tmp
copy *.png tmp
copy *.lua tmp
copy *.wav tmp
del tmp\*_raw.wav
copy level_* tmp
cd tmp
jar -cfM ..\Hotspot.love *
