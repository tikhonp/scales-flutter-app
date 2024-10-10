run:
	fvm flutter run

clean:
	fvm flutter clean

run_release:
	fvm flutter run --release

ios_build:
	fvm flutter build ipa --split-debug-info --obfuscate

