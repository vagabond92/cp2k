#!/bin/bash -e

# author: Ole Schuett

# shellcheck disable=SC1091
source /opt/cp2k-toolchain/install/setup

cd /workspace/cp2k
echo -n "Compiling cp2k... "
if make -j VERSION=pdbg &> /dev/null ; then
   echo "done."
else
   echo -e "failed.\n\n"
   echo "Summary: Compilation failed."
   echo "Status: FAILED"
   exit
fi

echo -e "\n========== Installing CP2K =========="
# The cp2k main binary is used by ase/test/cp2k/cp2k_dcd.py.
# https://gitlab.com/ase/ase/merge_requests/1109
cat > /usr/bin/cp2k << EndOfMessage
#!/bin/bash -e
source /opt/cp2k-toolchain/install/setup
mpiexec -np 2 /workspace/cp2k/exe/local/cp2k.pdbg "\$@"
EndOfMessage
chmod +x /usr/bin/cp2k

echo -e "\n========== Installing ASE =========="
cd /opt/ase/
git pull
pip3 install .

echo -e "\n========== Running ASE Tests =========="
cd /opt/ase/
export ASE_CP2K_COMMAND="mpiexec -np 2 /workspace/cp2k/exe/local/cp2k_shell.pdbg"

set +e # disable error trapping for remainder of script
(
set -e # abort if error is encountered
for i in ./ase/test/cp2k/cp2k_*.py
do
  echo "Running $i ..."
  python3 "$i" |& tee "/tmp/test_ase.out"
  if grep "Exception ignored" "/tmp/test_ase.out" ; then
    exit 1  # Found unraisable exception, e.g. in __del__.
  fi
done
)

EXIT_CODE=$?

echo ""

ASE_REVISION=$(git rev-parse --short HEAD)
if (( EXIT_CODE )); then
    echo "Summary: Something is wrong with ASE commit ${ASE_REVISION}."
    echo "Status: FAILED"
else
    echo "Summary: ASE commit ${ASE_REVISION} works fine."
    echo "Status: OK"
fi

#EOF
