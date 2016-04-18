#!/bin/awk -f

#freemem(K) | cpu idle(%)
BEGIN{
    interval = 5;
    if(ARGV[1]) interval = ARGV[1];
    ocpu = 0; ncpu = 0; dcpu = 0; pec = 0.0;
    oidle = 0; nidle = 0; didle = 0;  # %idle = (newidle - oldidle)/(newcpu - newcpu)
    free = 0;
    sep = "	";

    printf("FreeMem" sep "Idle\n")
    while(getline < "/proc/stat") {  #get init value
            if($0 ~ /cpu /) {
                #user nice system idle io irq sirq 
                ncpu = $2 + $3 + $4 + $5 + $6 + $7 + $8;
                nidle = $5;
		break;
            }
        }
        close("/proc/stat");

    while(system("trap 'exit 0' 2; sleep "interval";exit 1")) {
        while(getline < "/proc/meminfo") {  #print free mem
            if($0 ~ /MemFree/) {
                printf($2);    
		break;
            }
        }
        close("/proc/meminfo");

	printf(sep);

        while(getline < "/proc/stat") {  #print idle
            if($0 ~ /cpu /) {
                #user nice system idle io irq sirq 
                ncpu = $2 + $3 + $4 + $5 + $6 + $7 + $8;
                nidle = $5;
                dcpu = ncpu - ocpu;
                didle = nidle - oidle;
                if (dcpu == 0)
                    pec = 0;
                else
                    pec = didle/dcpu;
                printf("%.2f", pec * 100);
		break;
            }
        }
        close("/proc/stat");

	printf("\n");
    }
}
