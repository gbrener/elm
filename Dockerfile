FROM ubuntu:16.04

# Install dependencies, create "elm" user
RUN apt-get update && \
    apt-get install -y wget bzip2 git && \
    useradd --create-home \
            --shell /bin/bash \
            --user-group \
            elm && \
    echo 'elm:elm' | chpasswd && \
    apt-get clean -y && \
    rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/*

# Add files used for development
ADD . /home/elm/elm

# Run chown so we can install
RUN chown -R elm /home/elm/elm

# Login as the elm user
USER elm
WORKDIR /home/elm/

# Install Miniconda
RUN wget https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh && \
    bash Miniconda3-latest-Linux-x86_64.sh -b -p /home/elm/miniconda && \
    echo 'export PATH="/home/elm/miniconda/bin:${PATH}"' >> ~/.bashrc
ENV PATH="/home/elm/miniconda/bin:${PATH}"

# Clone down repos, create unified conda environment
RUN git clone https://github.com/ContinuumIO/earthio.git && \
    git clone https://github.com/ContinuumIO/xarray_filters.git && \
    conda create -n elm-env -y python=3.5 && \
    conda env update -n elm-env -f earthio/environment.yml && \
    conda env update -n elm-env -f elm/environment.yml && \
    cd xarray_filters && ~/miniconda/envs/elm-env/bin/python setup.py install && cd - && \
    cd earthio && ~/miniconda/envs/elm-env/bin/python setup.py install && cd - && \
    cd elm && ~/miniconda/envs/elm-env/bin/python setup.py install && cd - && \
    conda clean --all -y && \
    rm -rf /home/elm/elm /home/elm/earthio /home/elm/xarray_filters

# Expose port for Jupyter
EXPOSE 8888
