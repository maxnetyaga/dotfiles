from setuptools import setup, find_packages

setup(
    name='html_parser',
    version='0.1.0',
    packages=find_packages(),  # auto-discovers all modules
    install_requires=["bs4", "psycopg2"],       # add dependencies here if any
    author='Max Netyaga',
    author_email='max.netyaga@gmail.com',
    description='A short description of your package',
    long_description=open('README.md').read(),
    long_description_content_type='text/markdown',
    python_requires='>=3.13',
)
