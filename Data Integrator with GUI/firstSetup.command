which -s brew
if [[ $? != 0 ]] ; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    brew update
fi

brew install sqlite
brew install python3
pip3 install gpx_converter
pip3 install pytest.qt

echo "python3 -m venv integrator/venv"

chmod u+x CLI/runCLI.command
chmod u+x runGUI.command
chmod u+x runTest.command

