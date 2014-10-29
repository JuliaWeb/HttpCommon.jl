if VERSION < v"0.4-"
    using Dates
else
    using Base.Dates
end

using FactCheck
using HttpCommon

facts("HttpCommon utility functions") do

    context("RFC1123 compliant datetimes") do
        @fact RFC1123_datetime(DateTime(2013, 5, 2, 13, 45, 7)) =>
            "Thu, 02 May 2013 13:45:07 GMT"
    end

    context("Escape HTML") do
        @fact escapeHTML("<script type='text/javascript'>alert('sucker');</script> foo bar") =>
            "&lt;script type='text/javascript'&gt;alert('sucker');&lt;/script&gt; foo bar"
    end

    context("Decode URI") do
        @fact decodeURI("%3Ca+href%3D%27foo%27%3Ebar%3C%2Fa%3Erun%26%2B%2B") =>
            "<a href='foo'>bar</a>run&++"
    end

    context("Encode URI") do
        @fact encodeURI("<a href='foo'>bar</a>run&++") =>
            "%3Ca%20href%3D%27foo%27%3Ebar%3C%2Fa%3Erun%26%2B%2B"
    end

    context("Parse URL query strings") do
        @fact parsequerystring("foo=%3Ca%20href%3D%27foo%27%3Ebar%3C%2Fa%3Erun%26%2B%2B&bar=123") =>
            ["foo" => "<a href='foo'>bar</a>run&++", "bar" => "123"]
    end
end

# Check doesn't throw
RFC1123_datetime()

facts("Headers") do
    context("Headers with duplicates") do
        h = Headers()
        @fact length(h) => 0

        h["Content-Type"] = "text/html"
        @fact length(h) => 1

        h["Set-Cookie"] = "user=me;"
        @fact length(h) => 2

        h["Set-Cookie"] = "pass=secret;"
        @fact length(h) => 3

        @fact h["Content-Type"] => "text/html"
        @fact headersforkey(h, "Set-Cookie") => ["user=me;", "pass=secret;"]
        @fact h |> collect |> sort => [("Content-Type", "text/html"),
                                       ("Set-Cookie", "pass=secret;"),
                                       ("Set-Cookie", "user=me;")]

        delete!(h, "Set-Cookie")
        @fact length(h) => 1
        @fact h["Content-Type"] => "text/html"
        @fact get(h, "Set-Cookie", "**DEFAULT**") => "**DEFAULT**"
    end
end
