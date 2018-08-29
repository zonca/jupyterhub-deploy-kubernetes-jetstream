alias k="sudo kubectl"
alias h="sudo helm"

kn () {
    sudo kubectl -n $N $@;
}

ks () {
    sudo kubectl exec -n $N -it $1 -- /bin/bash
}
