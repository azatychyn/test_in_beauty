import Ecto.Query
# import InBeauty.Factories

alias InBeauty.Repo

alias InBeauty.Accounts
alias InBeauty.Accounts.{ User, UserToken }
alias InBeauty.Catalogue
alias InBeauty.Catalogue.{ Product, Review, Stock, ReservedStock }
alias InBeauty.Deliveries
alias InBeauty.Deliveries.{ Delivery, DeliveryPoint }
alias InBeauty.Payments
alias InBeauty.Payments.Cart
alias InBeauty.Payments.Order
alias InBeauty.Relations.{ StockCart, StockOrder, FavoriteProduct }
