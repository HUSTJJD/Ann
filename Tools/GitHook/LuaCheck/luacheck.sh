for file in `git diff --cached --name-only $against`; do
	if [ "${file##*.}" == "lua" ]; then
		luacheck $file
	fi
done
 
 
ret="$?"
if [ "$ret" != 0 ]; then
	exit "$ret"
fi