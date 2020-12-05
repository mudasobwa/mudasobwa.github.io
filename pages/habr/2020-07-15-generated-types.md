Типы, где их не ждали


Давайте представим себе реализацию модуля `scaffold`, который генерирует структуру с предопределенными пользовательскими полями и инжектит ее в вызываемый модуль при помощи `use Scaffold`. При вызове `use Scaffold, fields: foo: [custom_type()], ...` — мы хотим реализовать правильный тип в `Consumer` модуле (`common_field` в примере ниже определен в  `Scaffold` или еще где-нибудь извне).

```elixir
@type t :: %Consumer{
  common_field: [atom()],
  foo: [custom_type()],
  ...
}
```

Было бы крутоо, если бы мы могли точно сгенерировать тип `Consumer.t()` для дальнейшего использования и создать соответствующую документацию для пользователей нашего нового модуля.

![Lighthouse in French Catalonia](https://habrastorage.org/webt/zy/46/4x/zy464xmqifsrwocbtu1rynjdgrk.jpeg)

<cut text="Генерация типа структуры без СМС"/>

Пример посложнее будет выглядеть так:

```elixir
defmodule Scaffold do
  defmacro __using__(opts) do
    quote do
      @fields unquote(opts[:fields])
      @type t :: %__MODULE__{
        version: atom()
        # magic
      }
      defstruct @fields
    end
  end
end

defmodule Consumer do
  use Scaffold, fields: [foo: integer(), bar: binary()]
end
```

и, после компиляции:

```elixir
defmodule Consumer do
  @type t :: %Consumer{
    version: atom(),
    foo: integer(),
    bar: binary()
  }
  defstruct ~w|version foo bar|a
end
```

Вышлядит несложно, да?

### Наивный подход

Давайте начнем с анализа того, что за AST мы получим в `Scaffold.__using__/1`.

```elixir
  defmacro __using__(opts) do
    IO.inspect(opts)
  end
#⇒ [fields: [foo: {:integer, [line: 2], []},
#            bar: {:binary, [line: 2], []}]]
```

Отлично. Выглядит так, как быдто мы в шаге от успеха.

```elixir
  quote do
    custom_types = unquote(opts[:fields])
    ...
  end
#⇒ == Compilation error in file lib/consumer.ex ==
#  ** (CompileError) lib/consumer.ex:2: undefined function integer/0
```

Бамс! Типы — это чего-то особенного, как говорят в районе Привоза; мы не можем просто взять и достать их из AST где попало. Может быть, `unquote` по месту сработает?

```elixir
      @type t :: %__MODULE__{
              unquote_splicing([{:version, atom()} | opts[:fields]])
            }
#⇒ == Compilation error in file lib/scaffold.ex ==
#  ** (CompileError) lib/scaffold.ex:11: undefined function atom/0
```

Как бы не так. Типы — это утомительно; спросите любого, кто зарабатывает на жизнь хаскелем (и это еще в хаскеле типы не здорового человека, а курильщика; настоящие — зависимые — типы в сто раз полезнее, но еще в двести раз сложнее).

Ладно, кажется, нам нужно собрать все это объявление в AST и инжектнуть его целиком, а не по частям, чтобы компилятор увидел сразу правильное объявление.

### Построение типа в AST

Я опущу тут пересказ нескольких часов моих метаний, мучений, и тычков пальцем в небо. Все знают, что я пишу код в основном наугад, ожидая, что вдруг какая-нибудь комбинация этих строк скомпилируется и заработает. В общем, сложности тут с контекстом. Мы должны пропихнуть полученные определения полей в неизменном виде напрямую в макрос, объявляющий тип, ни разу не попытавшись это AST анквотнуть (потому что в момент `unquote` типы наподобие `binary()` будут немедленно приняты за обыкновенную функцию и ~~убиты из базуки~~ вызваны компилятором напрямую, приводя к `CompileError`.

Кроме того, мы не можем использовать обычные функции _внутри_ `quote do`, потому что все содержимое блока, переданного в `quote`, уже само по себе — AST.

```elixir
quote do
  Enum.map([:foo, :bar], & &1)
end
#⇒ {
#   {:., [], [{:__aliases__, [alias: false], [:Enum]}, :map]}, [],
#     [[:foo, :bar], {:&, [], [{:&, [], [1]}]}]}
```

Видите? Вместо вызова функции, мы получили ее препарированное AST, все эти `Enum`, `:map`, и прочий маловнятный мусор. Иными словами, нам придется создать AST определения типа вне блока `quote` и потом просто анквотнуть внутри него. Давайте попробуем.

### Чуть менее наивная попытка

Итак, нам надо _инжектнуть_ AST как AST, не пытаясь его анквотнуть. Звучит устрашающе?  — Вовсе нет, отнюдь.

```elixir
defmacro __using__(opts) do
  fields = opts[:fields]
  keys = Keyword.keys(fields)
  type = ???

  quote location: :keep do
    @type t :: unquote(type)
    defstruct unquote(keys)
  end
end
```

Все, что нам нужно сделать сейчас, — это произвести надлежащий AST, все остальное в порядке. Ну, пусть _Elixir_ сделает это за нас!

```elixir
iex|1 ▶ quote do
...|1 ▶   %Foo{version: atom(), foo: binary()}
...|1 ▶ end
#⇒ {:%, [],
#   [
#     {:__aliases__, [alias: false], [:Foo]},
#     {:%{}, [], [version: {:atom, [], []}, foo: {:binary, [], []}]}
#   ]}
```

А нельзя ли попроще?

```elixir
iex|2 ▶ quote do
...|2 ▶   %{__struct__: Foo, version: atom(), foo: binary()}
...|2 ▶ end
#⇒ {:%{}, [],
#   [
#     __struct__: {:__aliases__, [alias: false], [:Foo]},
#     version: {:atom, [], []},
#     foo: {:binary, [], []}
#   ]}
```

Ну, по крайней мере, выглядит это не слишком отталкивающе и достаточно многообещающе. Пора переходить к написанию рабочего кода.

### Почти работающее решение

```elixir
defmacro __using__(opts) do
  fields = opts[:fields]
  keys = Keyword.keys(fields)
  type =
    {:%{}, [],
      [
        {:__struct__, {:__MODULE__, [], Elixir}},
        {:version, {:atom, [], []}}
        | fields
      ]}

  quote location: :keep do
    @type t :: unquote(type)
    defstruct unquote(keys)
  end
end
```

или, если нет цели пробросить типы из собственно `Scaffold`, даже проще (как мне вот тут подсказали: [_Qqwy_ here](https://elixirforum.com/t/how-to-generate-custom-types-with-macros/33122/4?u=mudasobwa)). Осторожно, оно не будет работать с проброшенными типами, `version: atom()` за пределами блока `quote` выбросит исключение.

```elixir
defmacro __using__(opts) do
  fields = opts[:fields]
  keys = Keyword.keys(fields)
  fields_with_struct_name = [__struct__: __CALLER__.module] ++ fields

  quote location: :keep do
    @type t :: %{unquote_splicing(fields_with_struct)}
    defstruct unquote(keys)
  end
end
```

Вот что получится в результате генерации документации для целевого модуля (`mix docs`):

![Screenshot of type definition](https://habrastorage.org/webt/3s/yl/3n/3syl3nqdijehmt3j0zxmovvrjto.png)

### Примечание: трюк с фрагментом AST

Но что, если у нас уже есть сложный блок AST внутри нашего `__using__/1` макроса, который использует значения в кавычках? Переписать тонну кода, чтобы в результате запутаться в бесконечной череде вызовов `unquote` изнутри `quote`? Это просто даже не всегда возможно, если мы хотим иметь доступ ко всему, что объявлено внутри целевого модуля. На наше счастье, существует способ попроще.

> **NB** для краткости я покажу простое решение для объявления всех пользовательских полей, имеющих тип `atom()`, которое тривиально расширяеься до принятия любых типов из входных параметров, включая внешние, такие как `GenServer.on_start()` и ему подобные. Эту часть я оставлю для энтузиастов в виде домашнего задания.

Итак, нам надо сгенерировать тип _внутри_ блока `quote do`, потому что мы не можем передавать туда-сюда `atom()` (оно взовется с `CompileError`, как я показал выше). Хначит, что-нибудь типа такого:

```elixir
keys = Keyword.keys(fields)
type =
  {:%{}, [],
    [
      {:__struct__, {:__MODULE__, [], Elixir}},
      {:version, {:atom, [], []}}
      | Enum.zip(keys, Stream.cycle([{:atom, [], []}]))
    ]}
```

Это все хорошо, но как теперь добавить этот АСТ в декларацию `@type`? На помощь приходит очень удобная функция эликсира под названием [Quoted Fragment](https://hexdocs.pm/elixir/Kernel.SpecialForms.html#quote/2-binding-and-unquote-fragments), специально добавленный в язык ради генерации кода во время компиляциию Например:

```elixir
defmodule Squares do
  Enum.each(1..42, fn i ->
    def unquote(:"squared_#{i}")(),
      do: unquote(i) * unquote(i)
  end)
end
Squares.squared_5
#⇒ 25
```

_Quoted Fragments_ автоматически распознаются компилятором внутри блоков `quote`, с напрямую переданным контекстом (`bind_quoted:`). Проще простого.

```elixir
defmacro __using__(opts) do
  keys = Keyword.keys(opts[:fields])

  quote location: :keep, bind_quoted: [keys: keys] do
    type =
      {:%{}, [],
        [
          {:__struct__, {:__MODULE__, [], Elixir}},
          {:version, {:atom, [], []}}
          | Enum.zip(keys, Stream.cycle([{:atom, [], []}]))
        ]}

    #          ⇓⇓⇓⇓⇓⇓⇓⇓⇓⇓⇓⇓⇓
    @type t :: unquote(type)
    defstruct keys
  end
end
```

Одинокий вызов `unquote/1` тут _разрешен_, потому что `bind_quoted:` был напрямую указан как первый аргумент в вызове `quote/2`.

---

Удачного внедрения!
