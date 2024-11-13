# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     CraqValidator.Repo.insert!(%CraqValidator.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias CraqValidator.Repo
alias CraqValidator.RequestForChange.Option
alias CraqValidator.RequestForChange.Question
alias CraqValidator.RequestForChange.Response

Repo.delete_all(Option)
Repo.delete_all(Response)
Repo.delete_all(Question)

{:ok, question_one} =
  Repo.insert(%Question{
    description: "My question #{System.unique_integer([:positive])}",
    kind: "multiple_choice",
    require_comment: true
  })

Repo.insert(%Option{
  description: "My option for question #{System.unique_integer([:positive])}",
  question_id: question_one.id
})

Repo.insert(%Option{
  description: "My option for question #{System.unique_integer([:positive])}",
  question_id: question_one.id
})

# {:ok, question_two} =
#   Repo.insert(%Question{
#     description: "My question #{System.unique_integer([:positive])}",
#     kind: "free_text"
#   })
