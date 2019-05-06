from setuptools import setup


setup(
    # Needed to silence warnings (and to be a worthwhile package)
    name='python_Q_wrapper',
    # url='https://github.com/',
    # author='',
    # author_email='',

    # Needed to actually package something
    packages=['Q'],

    # Needed for dependencies
    # install_requires=['numpy'],

    # *strongly* suggested for sharing
    version='0.1',

    # The license can be anything you like
    # license='',
    description='A python wrapper for Q',
    # We will also need a readme eventually (there will be a warning)
    # long_description=open('README.txt').read(),
)
