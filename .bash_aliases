alias k="sudo kubectl"
alias h="sudo helm"

kn () {
    sudo kubectl -n $N $@;
}
