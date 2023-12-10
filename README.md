[![Build](https://github.com/jsteinberg/ializer/workflows/Ruby/badge.svg)](https://github.com/jsteinberg/ializer/actions) [![Gem Version](https://badge.fury.io/rb/ializer.svg)](https://badge.fury.io/rb/ializer)

# {De | Ser} Ializer

A fast serializer/deserializer for Ruby Objects.

## Table of Contents

* [Design Goals](#design-goals)
* [Installation](#installation)
* [Usage](#usage)
  * [Configuration](#configuration)
  * [Model Definitions](#model-definitions)
  * [Serializer Definitions](#serializer-definitions)
  * [DeSerializer Definitions](#deserializer-definitions)
  * [De/Serializer Configuration](#deserializer-configuration)
  * [Object Serialization](#object-serialization)
  * [Object Deserialization](#object-deserialization)
* [Attributes](#attributes)
  * [Nested Attributes](#nested-attributes)
  * [Attribute Types](#attribute-types)
  * [Serialization Context](#serialization-context)
  * [Conditional Attributes](#conditional-attributes)
  * [Attribute Sharing](#attribute-sharing)
  * [Key Transforms](#key-transforms)
  * [Thread Safety](#thread-safety)
* [Performance Comparison](#performance-comparison)
* [Contributing](#contributing)

## Design Goals

* Simple Singular DSL for defining object-to-data and data-to-object mappings
* Support for nested object relationships
* Isolate serialization/parsing code from object to not pollute method space
* speed

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ializer'
```

Execute:

```bash
bundle install
```

Require:

```ruby
require 'ializer'
```

## Usage

### Configuration

```ruby
Ializer.setup do |config|
  config.key_transform = :dasherize # change serailized key names
  # or
  config.key_transformer = ->(key) {
    key.lowercase.undsercore + '1'
  }
  config.warn_on_default = true # outputs a warning to STDOUT(puts) if DefaultDeSer is used
  config.raise_on_default = false # raises an exception if the DefaultDeSer is used
  config.pagination_enabled = true # adds page_info to enummerable results
  # N.B. page info is required if pagination is enabled, otherwise it will return an empty hash

  # create custom page info keys that will read the object passed as context 
  # in the following example we will return the page_number key from the value of either .page or [:page] of the context object
  config.page_info = {
    page_number: :page,
  }
end

```

For more information, see [Key Transforms](#key-transforms) and [Attribute Types](#attribute-types) sections.

### Model Definitions

```ruby
class Order
  attr_accessor :id, :created_at, :items, :customer

  def initialize(attr = {})
    @id = attr[:id]
    @created_at = attr[:created_at]
    @items = attr[:items] || []
  end
end

class OrderItem
  attr_accessor :name, :price, :in_stock

  def initialize(attr = {})
    @name = attr[:name]
    @price = attr[:price]
    @in_stock = attr[:in_stock]
  end
end

class Customer
  attr_accessor :name, :email

  def initialize(attr = {})
    @name = attr[:name]
    @email = attr[:email]
  end
end
```

### Serializer Definition

```ruby
class OrderDeSer < Ser::Ializer
  integer    :id
  timestamp  :created_at

  nested     :items,       deser: OrderItemDeSer
  nested     :customer,    deser: CustomerDeSer
end

class OrderItemDeSer < Ser::Ializer
  string     :name
  decimal    :price
  boolean    :in_stock
end

class CustomerDeSer < Ser::Ializer
  string     :name
  string     :email
end
```

### DeSerializer Definition

`De::Ser::Ializers` can deserialize from JSON and serialize to JSON. If you only need serialization capabilities, you can inherit from, `Ser::Italizer` instead.

```ruby
class OrderDeSer < De::Ser::Ializer
  integer    :id
  timestamp  :created_at

  nested     :items,       deser: OrderItemDeSer,   model_class: OrderItem
  nested     :customer,    deser: CustomerDeSer,    model_class: Customer
end

class OrderItemDeSer < De::Ser::Ializer
  string     :name
  decimal    :price
  boolean    :in_stock
end

class CustomerDeSer < De::Ser::Ializer
  string     :name
  string     :email
end
```

### De/Ser::Ializer Configuration

You can override the global config for a specific `Ser::Ializer` or `De::Ser::Ializer` by calling the setup command.

**Note:** `setup` must be called at the beginning of the definition otherwise the default config will be used.

```ruby
class OrderDeSer < De::Ser::Ializer
  setup do |config|
    config.key_transform = :dasherize
  end

  integer    :id
  timestamp  :created_at

  nested     :items,       deser: OrderItemDeSer,   model_class: OrderItem
  nested     :customer,    deser: CustomerDeSer,    model_class: Customer
end
```

### Sample Object

```ruby
order = Order.new(id: 4, created_at: Time.now, items: [])
order.items << OrderItem.new(name: 'Baseball', price: BigDecimal('4.99'), in_stock: true)
order.items << OrderItem.new(name: 'Football', price: BigDecimal('14.99'), in_stock: false)
order.customer = Customer.new(name: 'Bowser', email: 'bowser@example.net')
```

### Object Serialization

#### Return a hash

```ruby
data = OrderDeSer.serialize(order)
```

#### Return Serialized JSON

Ializer relies on the [`MultiJson`](https://github.com/intridea/multi_json) gem for json serialization/parsing

```ruby
json_string = OrderDeser.serialize_json(order)
```

#### Serialized Output

```json
{
  "id": 4,
  "created_at": "2019-12-01T00:00:00.000-06:00",
  "items": [
    {
       "name": "Baseball",
       "decimal": "4.99",
       "in_stock": true
     },
     {
       "name": "Football",
       "decimal": "14.99",
       "in_stock": false
     }
  ],
  "customer": {
    "name": "Bowser",
    "email": "bowser@example.net"
  }
}
```

#### Serialize a collection

```ruby
data = OrderDeSer.serialize([order, order2])
```

#### Serialized Collection Output

```json
[
  {
    "id": 3,
    ...
  },
  {
    "id": 4,
    ...
  }
]
```

### Object Deserialization

**Note:** Objects that are parsed must have a zero argument initializer (ie: Object.new)

#### Parsing a hash

```ruby
model = OrderDeSer.parse(data, Order)

 => #<Order:0x00007f9e44aabd80 @id=4, @created_at=Sun, 01 Dec 2019 00:00:00 -0600, @items=[#<OrderItem:0x00007f9e44aab6f0 @name="Baseball", @in_stock=true, @price=0.499e1>, #<OrderItem:0x00007f9e44aab628 @name="Football", @in_stock=false, @price=0.1499e2>], @customer=#<Customer:0x00007f9e44aab498 @name="Bowser", @email="bowser@example.net">>
```

### Pagination

Pagination will return the response in the following format: 
```json
{
    "data": [ ... ],
    "page_info": { ... } // this is the same format as the page_info config
}
```
The `page_info` configuration will go through all the keys in the hash and call the method or if the method is unavailable it will return the value of the key with the same name, it can be either a symbol or a string

## Attributes

Attributes are defined in `ializer` using the `property` method.

By default, attributes are read directly from the model property of the same name.  In this example, `name` is expected to be a property of the object being serialized:

```ruby
class Customer < De::Ser::Ializer
  property :id,   type: :integer
  property :name, type: String
end
```

Custom typed methods also exist to provide a cleaner DSL.

```ruby
class Customer < De::Ser::Ializer
  integer :id
  string :name
end
```

### Nested Attributes

`ializer` was built for serialization and parsing of nested objects.  You can create a nested object via the `property` method or a specialized `nested` method.

The `nested` method allows you to define a deser inline.

```ruby
class OrderDeSer < De::Ser::Ializer
  integer    :id
  timestamp  :created_at

  nested     :items,       deser: OrderItemDeSer,   model_class: OrderItem
  # OR
  property   :items,       deser: OrderItemDeSer,   model_class: OrderItem

  nested     :customer,    model_class: Customer do
    string     :name
    string     :email
  end
end
```

The `property` method **DOES NOT** allow you to define a deser inline, but instead allows you to override the value of the field.

```ruby
class OrderDeSer < De::Ser::Ializer
  integer    :id
  property   :items,       deser: OrderItemDeSer,   model_class: OrderItem do |object, _context|
    object.items.select(&:should_display?)
  end
end
```

### Attribute Types

The following types are included with `ializer`

| Type       | method alias  | mappings                   |
|------------|---------------|----------------------------|
| BigDecimal | `decimal()`   | :BigDecimal, :decimal      |
| Boolean    | `boolean()`   | :Boolean, :boolean         |
| Date       | `date()`      | Date, :date                |
| Integer    | `integer()`   | Integer, :integer          |
| Float      | `float()`     | Float, :float              |
| Time       | `millis()`    | :Millis, :millis           |
| String     | `string()`    | String, :millis            |
| Symbol     | `symbol()`    | Symbol, :symbol, :sym      |
| Time       | `timestamp()` | Time, DateTime, :timestamp |
| Array      | `array()`     | :array                     |
| JSON       | `json()`      | :json                      |
| Default    | `default()`   | :default                   |

**Note: Array/JSON/Default just uses the current value of the field and will only properly deserialize if it is a standard json value type(number, string, boolean).**

#### Default Attribute Configuration Options

There are a few settings for dealing with the `DefaultDeSer`.

```ruby
Ializer.setup do |config|
  config.warn_on_default = true # outputs a warning to STDOUT(puts) if DefaultDeSer is used
  config.raise_on_default = false # raises an exception if the DefaultDeSer is used
end
```

Since `De::Ser::Ializer`s are configured on load, raising an exception should halt the application from starting(instead of silently failing later).  By default a warning is logged to `STDOUT`.

#### Registering Custom Attribute types

You can register your own types or override the provided types.  A custom attribute type DeSer must implement the following methods.  When registering, you must register with the base `Ser::Ializer` class.

```ruby
Ser::Ializer.register(method_name, deser, *mappings)
```

```ruby
class CustomDeSer
  def self.serialize(value, _context = nil)
    "#{value}_custom"
  end

  def self.parse(value)
    value.split("_")[0]
  end
end

Ser::Ializer.register(:custom, CustomDeSer, :custom)
```

Then you can use them as follows:

```ruby
class Customer < De::Ser::Ializer
  integer :id
  string :name
  custom :custom_prop
  # or
  property :custom_prop, type: :custom
end
```

To override the provided type desers, you do the following:

```ruby
class MyTimeDeSer
  def self.serialize(value, _context = nil)
    value.to_my_favorite_time_serialization_format
  end

  def self.parse(value)
    Time.parse_my_favorite_time_serialization_format(value)
  end
end

Ser::Ializer.register('timestamp', MyTimeDeSer, Time, DateTime, :timestamp)
```

Custom attributes that must be serialized but do not exist on the model can be declared using Ruby block syntax:

```ruby
class Customer < De::Ser::Ializer
  string :full_name do |object, _context|
    "#{object.first_name} (#{object.last_name})"
  end
end
```

The block syntax can also be used to override the property on the object:

```ruby
class Customer < De::Ser::Ializer
  string :name do |object, _context|
    "#{object.name} Part 2"
  end
end
```

You can also override the property on an object with a specially named method:

```ruby
class Customer < De::Ser::Ializer
  string :name

  def self.name(object, _context) # overrides :name attribute
    "#{object.name} Part 2"
  end
end
```

Setters can also be overridden:

```ruby
class Customer < De::Ser::Ializer
  string :name

  def self.name=(object, value)
    object.name = value.delete_suffix('Part 2')
  end
end
```

Attributes can also use a different name by passing the original method or accessor with a proc shortcut:

```ruby
class Customer < De::Ser::Ializer
  string :name, key: 'customer-name' # Note: an explicitly set key will not be transformed by the configured key_transformer
end
```

### Serialization Context

In some cases a `Ser::Ializer` might require more information than what is available on the record.  A context object can be passed to serialization and used however necessary.

```ruby
class CustomerSerializer < Ser::Ializer
  integer :id
  string :name

  string :phone_number do |object, context|
    if context.admin?
      object.phone_number
    else
      object.phone_number.last(4)
    end
  end
end

# ...

CustomerDeSer.serialize(order, current_user)
```

#### Using the context to serialize a subset of attributes

There are special keywords/method names on the Serialization Context that can be used to limit the attributes that are serialized.  This is different from conditional attributes below.  The conditions would still apply to the subset.

If your serialization context is a `Hash`, you can use the hash keys `:attributes` or `:include` to define the limited subset of attributes for serialization.

```ruby
CustomerDeSer.serialize(order, attributes: [:name])
```

If your serialization context is a ruby object, a method named `attributes` that returns an array of attribute names can be used.

```ruby
class AttributeSubsetContext
  attr_accessor :attributes
end

context = AttributeSubsetContext.new(attributes: [:name])
CustomerDeSer.serialize(order, context)
```

### Conditional Attributes

Conditional attributes can be defined by passing a Proc to the `if` key on the `property` method. Return `truthy` if the attribute should be serialized, and `falsey` if not. The record and any params passed to the serializer are available inside the Proc as the first and second parameters, respectively.

```ruby
class CustomerSerializer < Ser::Ializer
  integer :id
  string :name

  string :phone_number if: ->(object, context) { context.admin? }
end

# ...
CustomerDeSer.serialize(order, current_user)
```

**Note: instead of a Proc, any object that responds to call with arity 2 can be passed to `:if`.**

```ruby
class AdminChecker
  def self.admin?(_object, context)
    context.admin?
  end
end

class CustomerSerializer < Ser::Ializer
  integer :id
  string :name

  string :phone_number if: AdminChecker.method(:admin?)
end

# ...
CustomerDeSer.serialize(order, current_user)
```

### Attribute Sharing

There are a couple of ways to share attributes from different desers.

#### Inheritance

```ruby
class SimpleUserDeSer < De::Ser::Ializer
  integer :id
  string  :username
end

class UserDeSer < SimpleUserDeSer
  string  :email
end
```

#### Composition

```ruby
class BaseApiDeSer < De::Ser::Ializer
  integer    :id
  timestamp  :created_at
end

class UserDeSer < De::Ser::Ializer
  with BaseApiDeSer
  string  :email
end
```

**Note:** Including a deser using `with` will include any method overrides.

```ruby
class BaseApiDeSer < De::Ser::Ializer
  integer    :id
  timestamp  :created_at
  timestamp  :updated_at

  def self.created_at(object, context)
    # INCLUDED IN UserDeSer
  end

  def self.updated_at(object, context)
    # NOT INCLUDED IN UserDeSer(Overridden below)
  end
end

class UserDeSer < De::Ser::Ializer
  with BaseApiDeSer
  string  :email

  def self.updated_at(object, context)
    # INCLUDED IN UserDeSer.
  end
end
```

For more examples check the [`spec/support/deser`](https://github.com/jsteinberg/ializer/tree/master/spec/support/deser) folder.

### Key Transforms

By default `ializer` uses object field names as the key name. You can override this setting by either specifying a string method for transforms or providing a proc for manual transformation.

**Note:** `key_transformer` will override any value set as the `key_transform`

```ruby
Ializer.setup do |config|
  config.key_transform = :dasherize
end

# or

Ializer.setup do |config|
  config.key_transformer = ->(key) {
    key.lowercase.undsercore + '1'
  }
end

```

### Thread Safety

Defining of desers is not thread safe.  As long as defitions are preloaded then thread safety is not a concern.  **Note: because of this you should not create desers at runtime**

## Performance Comparison

TODO

## Contributing

TODO
