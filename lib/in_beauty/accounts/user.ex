defmodule InBeauty.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias InBeauty.Deliveries.Delivery

  @fields ~w(id email password hashed_password confirmed_at role first_name last_name patronymic phone_number)a
  @phone ~r/^(\+?\d{7,8}\s)?\(?\d{3}\)?[\s.-]?\d{3}[\s.-]?\d{4}$/

  @derive {Inspect, except: [:password]}
  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
#TODO validate name adn make its changeset for fist name last name and patronymic
  schema "users" do
    field :email, :string
    field :password, :string, virtual: true
    field :hashed_password, :string
    field :confirmed_at, :naive_datetime
    field :role, Ecto.Enum, values: [:user, :admin, :anon]
    field :first_name, :string
    field :last_name, :string
    field :patronymic, :string
    field :phone_number, :string

    has_many :deliveries, Delivery, on_replace: :delete, on_delete: :delete_all
    timestamps()
  end

  @doc """
  A user changeset that includes fields changesets.
  """
  def changeset(%__MODULE__{} = user, attrs) do
    user
    |> cast(attrs, @fields)
    |> cast_embed(:delivery, with: &embed_changeset/2)
    |> validate_email()
    |> validate_phone_number()
  end

  defp embed_changeset(schema, params) do
    changed_fields = schema |> Map.from_struct() |> Map.keys()
    cast(schema, params, changed_fields)
  end

  @doc """
  A user changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def registration_changeset(%__MODULE__{} = user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:email, :password, :phone_number, :first_name, :role])
    |> validate_required([:role, :first_name])
    |> validate_email()
    |> validate_password(opts)
    |> validate_phone_number()
  end

  defp validate_phone_number(changeset) do
    changeset
    |> format_phone_number()
    |> validate_required([:phone_number])
    |> validate_length(:phone_number, min: 11, max: 11)
    |> validate_format(:phone_number, ~r/^7[0-9]*$/, message: "must start with +7..........")
    |> unique_constraint(:phone_number)
  end

  defp validate_email(changeset) do
    changeset
    |> validate_required([:email])
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/, message: "must have the @ sign and no spaces")
    |> validate_length(:email, max: 160)
    |> unique_constraint(:email)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> validate_required([:password])
    |> validate_length(:password, min: 12, max: 80)
    |> validate_format(:password, ~r/[a-z]/, message: "should be at least one lower case character")
    |> validate_format(:password, ~r/[A-Z]/, message: "should be at least one upper case character")
    |> validate_format(:password, ~r/[!?@#$%^&*_0-9]/,
      message: "at least one digit or punctuation character"
    )
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      |> put_change(:hashed_password, Bcrypt.hash_pwd_salt(password))
      |> delete_change(:password)
    else
      changeset
    end
  end

  @doc """
  A user changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_changeset(%__MODULE__{} = user, attrs) do
    user
    |> cast(attrs, [:email])
    |> validate_email()
    |> case do
      %{changes: %{email: _}} = changeset -> changeset
      %{} = changeset -> add_error(changeset, :email, "did not change")
    end
  end

  @doc """
  A user changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_changeset(%__MODULE__{} = user, attrs, opts \\ []) do
    user
    |> cast(attrs, [:password])
    |> validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(changeset) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
    change(changeset, confirmed_at: now)
  end

  @doc """
  Verifies the password.

  If there is no user or the user doesn't have a password, we call
  `Bcrypt.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%InBeauty.Accounts.User{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Bcrypt.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Bcrypt.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      add_error(changeset, :current_password, "is not valid")
    end
  end

  defp format_phone_number(%{changes: %{phone_number: phone_number}} = changeset) do
    phone_number = String.replace(phone_number, ~r/(\s)?(\()?(\))?(\-)?(\+)?/, "")
    put_change(changeset, :phone_number, phone_number)
  end
  defp format_phone_number(changeset), do: changeset
end
