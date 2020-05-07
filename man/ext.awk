BEGIN				{ do = 0 }
/@(command|variable)/		{ do = 0 }
/@(command|variable).*database/	{ do = 1 }
do == 1
