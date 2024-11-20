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
alias CraqValidator.RequestForChange.Confirmation
alias CraqValidator.RequestForChange.Option
alias CraqValidator.RequestForChange.Question
alias CraqValidator.RequestForChange.Response

Repo.delete_all(Option)
Repo.delete_all(Response)
Repo.delete_all(Question)

{:ok, question_one} =
  Repo.insert(%Question{
    description: "This is an example of multiple choice question with comment required",
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

{:ok, question_two} =
  Repo.insert(%Question{
    description:
      "This is an example of multiple choice question without comment required and a terminal option",
    kind: "multiple_choice"
  })

Repo.insert(%Option{
  description: "My option for question #{System.unique_integer([:positive])}",
  question_id: question_two.id
})

Repo.insert(%Option{
  description: "This is a terminal option",
  question_id: question_two.id,
  is_terminal: true
})

{:ok, question_three} =
  Repo.insert(%Question{
    description: "This is an example of multiple choice question without comment required",
    kind: "multiple_choice"
  })

Repo.insert(%Option{
  description: "My option for question #{System.unique_integer([:positive])}",
  question_id: question_three.id
})

Repo.insert(%Option{
  description: "My option for question #{System.unique_integer([:positive])}",
  question_id: question_three.id
})

{:ok, question_four} =
  Repo.insert(%Question{
    description: "This is an example of free text question",
    kind: "free_text"
  })

{:ok, question_five} =
  Repo.insert(%Question{
    description: "This is an example of multiple choice question without comment required",
    kind: "multiple_choice"
  })

{:ok, option} =
  Repo.insert(%Option{
    description: "My option for question #{System.unique_integer([:positive])}",
    question_id: question_five.id,
    require_confirmation: true
  })

Repo.insert(%Confirmation{
  description: "This is a confirmation",
  option_id: option.id
})

Repo.insert(%Confirmation{
  description: "This is a confirmation",
  option_id: option.id
})

Repo.insert(%Option{
  description: "My option for question #{System.unique_integer([:positive])}",
  question_id: question_five.id
})
