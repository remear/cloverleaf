# cloverleaf

Rack middleware to enqueue Balanced events to RabbitMQ

### Usage

While there are several ways to run a Rack application, a common way is to use Puma.

```bash
puma config.ru -p 9294
```

To daemonize:

```bash
puma -d config.ru -p 9294
```