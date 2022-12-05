Rails.application.routes.draw do
  get "home", to: "main#home"
  get "help", to: "main#help"
  post "home", to: "main#set_data"
  get "download", to: "main#download", as: "download"
  root "main#home"
end