c = get_config()  #noqa

c.Spawner.notebook_dir = '/home/root'
c.Spawner.cmd = ['jupyter-labhub', '--allow-root']
c.JupyterHub.admin_access = True
c.Authenticator.allowed_users = {'root'}
