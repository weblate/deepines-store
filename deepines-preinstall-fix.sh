#!/bin/sh

Fmt="printf"

APTDIR=/etc/apt
SRCLIST=${APTDIR}/sources.list
DEEPINESLIST="${SRCLIST}.d/deepines.list"

STABLEDIST="apricot"
STABLEREPO="## Generated by deepin-installer
deb https://community-packages.deepin.com/deepin/ apricot main contrib non-free
#deb-src https://community-packages.deepin.com/deepin/ apricot main contrib non-free"

BETADIST="bullseye"
BETAREPO="## Generated by deepin-installer
deb https://proposed-packages.deepin.com/dde-nightly/ bullseye main contrib non-free
deb https://proposed-packages.deepin.com/dde-nightly/ deepin-bullseye main contrib non-free
deb https://proposed-packages.deepin.com/dde-nightly/ dde-bullseye main contrib non-free
deb https://proposed-packages.deepin.com/dde-nightly/ deepin-wine main contrib non-free
deb-src https://proposed-packages.deepin.com/dde-nightly/ bullseye main contrib non-free
deb-src https://proposed-packages.deepin.com/dde-nightly/ deepin-bullseye main contrib non-free
deb-src https://proposed-packages.deepin.com/dde-nightly/ dde-bullseye main contrib non-free
deb-src https://proposed-packages.deepin.com/dde-nightly/ deepin-wine main contrib non-free"

SEPARATOR="=============================================================="
SEPARATOR2="--------------------------------------------------------------"
INSTALLING_DEEPIN_REPO="Installing Deepin %d main repositories...\n"
INSTALLING_DONE="Done!\n"
INSTALLING_FAILED="Failed!\n"
NOT_SUPPORTED="This operating system is not Deepin 20 or Deepin 23."
ONLY_COMPATIBLE="  This repair script is only for Deepin 20 and Deepin 23.
  It should not be used on other Linux distributions."
SRC_LIST_CHECKING="Checking configuration of main repositories..."
SRC_LIST_ARE_RIGHT="Repositories configured correctly."
SRC_LIST_NOT_FOUND="$SRCLIST was not found."
SRC_LIST_NOT_RIGHT="$SRCLIST does not have the needed repositories."
SRC_LIST_IMPROPER="Improperly configured repositories."
SRC_LIST_IMPROPER2="These repositories are incorrectly configured
in /etc/apt/sources.list instead of being separate
files under /etc/apt/sources.list.d/"
CHOOSE_OPTION="Choose one of the following options:"
WANT_RESTORE_OPTIONS="  A) Restore the original repository configuration.

  X) Do not repair and exit."
NO_RESTORE="The Deepines Store may not be able to be installed
if these problems are not fixed first.

No changes have been made."
WRONG_OPTION="Wrong option"
YESEXPR="[yY]*"
YDEF="[Y/n]"
DEEPINES_STORE_FOUND="The Deepines Store is currently installed."
WANT_REMOVE_DEEPINES_STORE="Do you want to uninstall the Deepines Store?"
WANT_REMOVE_DEEPINES_REPO="Do you want to uninstall the Deepines Repository?"
DEEPINES_NO_STORE="The repository is installed, but the Deepines Store is not."
REPO_NO_PKG="Currently the repository package is no longer provided."
RECOMMENDED_DEEPINES="It is recommended to install the Deepines Store."
NO_DEEPINES="The Deepines Store is not installed.
You should not have any problems now."

case "${LANGUAGE:-$LANG}" in
es*)
    INSTALLING_DEEPIN_REPO="Instalando repositorios principales de Deepin %d...\n"
    INSTALLING_DONE="¡Hecho!\n"
    INSTALLING_FAILED="¡Falló!\n"
    NOT_SUPPORTED="Este sistema operativo no es Deepin 20 o Deepin 23."
    ONLY_COMPATIBLE=" Este script de reparación es sólo para Deepin 20 y Deepin 23.
 No debe usarse en otras distribuciones Linux."
    SRC_LIST_CHECKING="Comprobando configuración de los repositorios principales..."
    SRC_LIST_ARE_RIGHT="Repositorios configurados correctamente."
    SRC_LIST_NOT_FOUND="$SRCLIST no se encontró."
    SRC_LIST_NOT_RIGHT="$SRCLIST no tiene los repositorios necesarios."
    SRC_LIST_IMPROPER="Repositorios configurados de manera inadecuada"
    SRC_LIST_IMPROPER2="Estos repositorios están configurados de manera
inadecuada en /etc/apt/sources.list en lugar de
ser archivos separados en /etc/apt/sources.list.d/"
    CHOOSE_OPTION="Elija una de las siguientes opciones:"
    WANT_RESTORE_OPTIONS="  R) Restaurar la configuración original de repositorios.

  X) No reparar y salir."
    NO_RESTORE="Es posible que no se pueda instalar la Tienda Deepines
si estos problemas no se solucionan primero.

No se han realizado cambios."
    WRONG_OPTION="Opción incorrecta"
    YESEXPR="[sSyY]*"
    YDEF="[S/n]"
    DEEPINES_STORE_FOUND="La Tienda Deepines está actualmente instalada."
    WANT_REMOVE_DEEPINES_STORE="¿Desea desinstalar la Tienda Deepines?"
    WANT_REMOVE_DEEPINES_REPO="¿Desea desinstalar el Repositorio Deepines?"
    DEEPINES_NO_STORE="El repositorio está instalado, pero la Tienda Deepines no lo está."
    REPO_NO_PKG="Actualmente ya no se proporciona el paquete de repositorio."
    RECOMMENDED_DEEPINES="Se recomienda instalar la Tienda Deepines."
    NO_DEEPINES="La Tienda Deepines no está instalada.
No debería tener ningún problema ahora."
    ;;
esac

InstallTextToRepo() {
    sudo mkdir -p $APTDIR
    echo "$1" | sudo tee "${SRCLIST}"
}

InstallDeepinRepo() {
    echo
    echo "$SEPARATOR"
    $Fmt "${INSTALLING_DEEPIN_REPO}\n" "$1" && {
        InstallTextToRepo "$2" 2>&1
    } || {
        $Fmt "$INSTALLING_FAILED"
        echo "$SEPARATOR"
        exit 1
    } && $Fmt "$INSTALLING_DONE"
    echo "$SEPARATOR"
}

UnsupportedOS() {
    echo >&2 "$SEPARATOR"
    echo >&2 "$NOT_SUPPORTED"
    echo >&2
    echo >&2 "$ONLY_COMPATIBLE"
    echo >&2 "$SEPARATOR"
    exit 1
}

CheckBadRepos() {
    CHECKREPOS=$(grep -E '^deb' <"${SRCLIST}" | grep -Ev "^deb .*($1) ")
    if [ "${CHECKREPOS}" ]; then
        echo >&2 "$SRC_LIST_IMPROPER"
        echo >&2 "$SEPARATOR"
        echo >&2
        echo >&2 "$CHECKREPOS" | sed -e "s/deb h/\n  deb h/g; s/deb \[/\n  deb \[/g"
        echo >&2
        echo >&2 "$SEPARATOR"
        echo >&2 "$SRC_LIST_IMPROPER2"
        return 1
    else
        echo "$SRC_LIST_ARE_RIGHT"
        echo
        echo "$SEPARATOR"
        return 0
    fi
}

# If we reach here, then we have already made sure that the OS is really Deepin 20 or Deepin 23.
CheckRepos() {
    echo "$SEPARATOR"
    if [ -f "${SRCLIST}" ]; then
        echo "$SRC_LIST_CHECKING"
        echo
        DEBDIST=$(grep -E "^deb .*($1)? " "${SRCLIST}" | sed -r 's/^.* (\S+) main .*$/\1/g' | grep "$2")
        if [ -n "${DEBDIST}" ]; then
            CheckBadRepos "$1" && return 0
        else
            echo >&2 "$SRC_LIST_NOT_RIGHT"
            echo >&2
        fi
    else
        echo >&2 "$SRC_LIST_NOT_FOUND"
        echo >&2
    fi
    return 1
}

AnsweredYesTo() { # Xoas' Get Answer Function.
    $Fmt "%s " "$1 $YDEF"
    eval "case '$(head -n1)' in
    ($YESEXPR|'') return 0 ;; # Yes.
    (*) return 1 ;; esac      # No."
}

CheckDeepines() {
    if dpkg -s "deepines-store" >/dev/null 2>&1; then
        echo "$DEEPINES_STORE_FOUND"
        if AnsweredYesTo "$WANT_REMOVE_DEEPINES_STORE"; then
            sudo apt purge deepines-store -y && sudo apt autoremove --purge -y
        fi
    elif dpkg -s "deepines-repository" >/dev/null 2>&1; then
        echo "$REPO_NO_PKG"
        echo "$RECOMMENDED_DEEPINES"
        if AnsweredYesTo "$WANT_REMOVE_DEEPINES_REPO"; then
            sudo apt purge deepines-repository -y
        fi
    elif [ -f "${DEEPINESLIST}" ]; then
        echo "$DEEPINES_NO_STORE"
        echo "$RECOMMENDED_DEEPINES"
    else
        echo "$NO_DEEPINES"
    fi
}

WantRestoreRepos() {
    echo "$SEPARATOR2"
    echo "$CHOOSE_OPTION"
    echo
    echo "$WANT_RESTORE_OPTIONS"
    echo
    FINISH=0
    while [ $FINISH -eq 0 ]; do
        read -r SELECTEDOPTION
        case $SELECTEDOPTION in
        R | r)
            InstallDeepinRepo "$1" "$2" && FINISH=1 && return 0
            ;;
        X | x)
            echo >&2
            echo >&2 "$NO_RESTORE"
            FINISH=1
            exit 1
            ;;
        *)
            echo "$WRONG_OPTION"
            ;;
        esac
    done
}

Main() {
    DIST_ID=$(lsb_release -is)
    REL_NUM=$(lsb_release -rs)
    if [ "$DIST_ID" = "Deepin" ]; then
        case $REL_NUM in
        20 | 20.*)
            CheckRepos "/deepin/|/deepin-20-beta/" $STABLEDIST || WantRestoreRepos "20" "$STABLEREPO"
            ;;
        "23 Nightly" | 23 | 23.*)
            CheckRepos "/dde-nightly/" $BETADIST || WantRestoreRepos "23" "$BETAREPO"
            ;;
        *) UnsupportedOS ;;
        esac
    else
        UnsupportedOS
    fi
}

Main && CheckDeepines
