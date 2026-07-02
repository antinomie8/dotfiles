#import "@local/antoine:1.0.0": *
#set text(lang: "fr")
#show: setup.with(
	title: "Title",
	subtitle: "subtitle",
	author: "Antoine Saez Dumas",
	date: datetime.today().display("[day] [month repr:long] [year]"),
	maketitle: true,
)

