#!/bin/bash -eu

python_version="$1"
python=("python${python_version}")

echo "==> Checking full python version for python ${python_version}"

"${python[@]}" --version

echo "==> Selecting requirements for python ${python_version}"

freeze_dir="$(dirname "$0")/freeze-core"
requirements_dir="$(dirname "$0")/requirements-core"
default_requirements_dir="$(dirname "$0")/requirements"

version_requirements=()

if [[ "$(ls "${freeze_dir}")" ]]; then
    echo "Using requirements directory: ${freeze_dir}"
    cd "${freeze_dir}"

    constraints="${python_version}.txt"

    version_requirements+=("${python_version}.txt")
else
    echo "Using requirements directory: ${requirements_dir}"
    cd "${requirements_dir}"

    constraints="${default_requirements_dir}/constraints.txt"

    requirements=()

    for requirement in *.txt; do
        requirements+=("${requirement}")
    done

    for requirement in "${requirements[@]}"; do
        if [[ "${requirement}" =~ sanity\. ]]; then
            # additional sanity test requirements are only needed for python 3.6
            if [[ "${python_version}" != "3.6" ]]; then
                continue
            fi
        elif [[ "${requirement}" =~ units\. ]]; then
            # unit tests run against all python versions
            true
        elif [[ "${requirement}" =~ integration\. ]]; then
            # integration tests run on python 2.7 and python 3.6
            if [[ "${python_version}" != "2.7" ]] && [[ "${python_version}" != "3.6" ]]; then
                continue
            fi
        else
            echo "ERROR: unhandled requirements file: ${requirement}"
            exit 1
        fi

        version_requirements+=("${requirement}")
    done
fi

echo "Using constraints file: ${constraints}"

if [[ "${python_version}" = "2.6" ]]; then
    # DEPRECATION: Python 2.6 is no longer supported by the Python core team, please upgrade your Python. A future version of pip will drop support for Python 2.6
    python+=(-W 'ignore:Python 2.6 is no longer supported ')
    # /tmp/{random}/pip.zip/pip/_vendor/urllib3/util/ssl_.py:339: SNIMissingWarning: An HTTPS request has been made, but the SNI (Subject Name Indication) extension to TLS is not available on this platform. This may cause the server to present an incorrect TLS certificate, which can cause validation failures. You can upgrade to a newer version of Python to solve this. For more information, see https://urllib3.readthedocs.io/en/latest/advanced-usage.html#ssl-warnings
    python+=(-W 'ignore:An HTTPS request has been made, but the SNI ')
    # /tmp/{random}/pip.zip/pip/_vendor/urllib3/util/ssl_.py:137: InsecurePlatformWarning: A true SSLContext object is not available. This prevents urllib3 from configuring SSL appropriately and may cause certain SSL connections to fail. You can upgrade to a newer version of Python to solve this. For more information, see https://urllib3.readthedocs.io/en/latest/advanced-usage.html#ssl-warnings
    python+=(-W 'ignore:A true SSLContext ')
elif [[ "${python_version}" = "2.7" ]]; then
    # DEPRECATION: Python 2.7 reached the end of its life on January 1st, 2020. Please upgrade your Python as Python 2.7 is no longer maintained. pip 21.0 will drop support for Python 2.7 in January 2021. More details about Python 2 support in pip can be found at https://pip.pypa.io/en/latest/development/release-process/#python-2-support pip 21.0 will remove support for this functionality.
    python+=(-W 'ignore:DEPRECATION')
elif [[ "${python_version}" = "3.5" ]]; then
    # DEPRECATION: Python 3.5 reached the end of its life on September 13th, 2020. Please upgrade your Python as Python 3.5 is no longer maintained. pip 21.0 will drop support for Python 3.5 in January 2021. pip 21.0 will remove support for this functionality.
    python+=(-W 'ignore:DEPRECATION')
fi

pip=("${python[@]}" -m pip.__main__ --disable-pip-version-check --no-cache-dir)
pip_install=("${pip[@]}" install)
pip_list=("${pip[@]}" list "--format=columns")
pip_check=("${pip[@]}" check)

if [[ "${python_version}" = "3.8" ]]; then
    pip_install+=(--no-warn-script-location)
fi

echo "==> Checking full pip version for python ${python_version}"

"${pip[@]}" --version

for requirement in "${version_requirements[@]}"; do
    echo "==> Installing requirements for python ${python_version}: ${requirement}"

    "${pip_install[@]}" -c "${constraints}" -r "${requirement}"
done

after=$("${pip_list[@]}")

for requirement in "${version_requirements[@]}"; do
    echo "==> Checking for requirements conflicts for python ${python_version}: ${requirement}"

    before="${after}"

    "${pip_install[@]}" -c "${constraints}" -r "${requirement}"

    after=$("${pip_list[@]}")

    if [[ "${before}" != "${after}" ]]; then
        echo "==> Conflicts detected in requirements for python ${python_version}: ${requirement}"
        echo ">>> Before"
        echo "${before}"
        echo ">>> After"
        echo "${after}"
        exit 1
    fi
done

echo "==> Checking for conflicts between installed packages for python ${python_version}"

"${pip_check[@]}"

echo "==> Finished with requirements for python ${python_version}"
