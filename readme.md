# PDQ to go!
> The old good PDQ on web!

I was dreaming one day to be able to do back of the envelope scalability calculations. Like if i provision faster CPUs, or run 2 nodes side by side, or maybe sharding, or how much headroom is left. Now YOU can, use [PDQtoGO](http://pdqtogo.com)!

![](docs/gopdq-demo.gif)

## Run locally

OS X & Linux & Windows:

```sh
docker pull i95north/pdqtogo:latest
```

## Development setup

The develpment environment is intentionally boring. As long as you have docker running then `it should just work`

```sh
// rebuild
sh scripts/rebuild-continer.sh

// this how you run it in development mode
sh scripts/run-bash-it.sh

// run it like in prod
sh scripts/run-it.sh

// run in prod
sh docker run -d -p 80:8080 i95north/pdqtogo:latest
```

## Contributing

1. Fork it (<https://github.com/i95north/pdqtogo/fork>)
2. Create your feature branch (`git checkout -b feature/fooBar`)
3. Commit your changes (`git commit -am 'Add some fooBar'`)
4. Push to the branch (`git push origin feature/fooBar`)
5. Create a new Pull Request

## Authors

* **Ruslan Rusu** - *Initial work* 

## License

This project is licensed under the MIT License - see the https://opensource.org/licenses/MIT

## Acknowledgments

* [Neil Gunther, @DrQz](https://twitter.com/DrQz)
