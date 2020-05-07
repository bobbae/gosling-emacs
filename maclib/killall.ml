jobs >~/.pcs
foreach i (`sed 's/.*\[\(.*\)\].*/\1/' ~/.pcs`)
	res $i
end
