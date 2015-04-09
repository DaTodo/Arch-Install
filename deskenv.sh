#!/bin/bash

function  usage
{
	echo "usage: deskenv [option][option]...."
	echo "options: [-g | --gnome] [-i | --i3]"
}

function graphics
{
intel=
nvidia=
card=$(lspci | grep VGA)

if [ "$card" != "" ]; then
	case "$card" in
		*Intel* )	intel=1
				;;
		*nvidia* ) 	nvidia=1
				;;	
	esac
fi

if [ "$intel" = "1" ]; then
        echo "intel install"
        #pacman -S xf86-video-intel
	main
        else
        echo "not 1"
fi

if [ "$nvidia" = "1" ]; then
        echo "nvidia install"
        #pacman -S xf86-video-nouveau
fi
   
}

function main
{

gnome=
i3=

while [ "$1" != "" ]; do
    case "$1" in
        -g | --gnome )          shift
				gnome=1
                                ;;
        -i | --i3 )             i3=1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
         * )                    usage
                                exit 1
    esac
    shift
done

if [ "$gnome" = "1" ]; then
        echo "gnome install"
fi

if [ "$i3" = "1" ]; then
        echo "i3 install"
fi

}
main
#graphics
