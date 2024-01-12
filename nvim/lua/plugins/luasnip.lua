-- Luasnip (snippets)
-- https://github.com/L3MON4D3/LuaSnip
local M = { "L3MON4D3/LuaSnip", event = "VeryLazy" }

function M.config()
  require("luasnip.loaders.from_vscode").lazy_load({
    paths = {
      "~/cs/dotfiles/nvim/snippets"
    }
  })

  local ls = require("luasnip")
  local types = require("luasnip.util.types")

  local s = ls.snippet
  local sn = ls.snippet_node
  local t = ls.text_node
  local i = ls.insert_node
  local f = ls.function_node
  local c = ls.choice_node
  local d = ls.dynamic_node
  local r = ls.restore_node
  local l = require("luasnip.extras").lambda
  local rep = require("luasnip.extras").rep
  local p = require("luasnip.extras").partial
  local m = require("luasnip.extras").match
  local n = require("luasnip.extras").nonempty
  local dl = require("luasnip.extras").dynamic_lambda
  local fmt = require("luasnip.extras.fmt").fmt
  local fmta = require("luasnip.extras.fmt").fmta
  local types = require("luasnip.util.types")
  local conds = require("luasnip.extras.expand_conditions")

  local same = function(index)
    return f(function(arg) return arg[1] end, { index })
  end

  local rust_get_test_result = function(position)
    return d(position, function()
      local nodes = {}

      table.insert(nodes, t " ")
      table.insert(nodes, t " -> Result<(), Error> ")

      local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false);
      for _, line in ipairs(lines) do
        if line:match("anyhow::Result") then
          table.insert(nodes, t " -> Result<()> ")
          break
        end
      end

      return sn(nil, c(1, nodes))
    end, {})
  end

  local rust_cargo_get_latest_version = function(name)
    local nodes = {}
    table.insert(nodes, i(nil, "version"))

    local file = io.popen("cargo search --limit 1 " .. name ..
      " | head -1 | awk '{print $3}' | tr -d '\"'")
    if file then
      local version = nil
      for line in file:lines() do
        version = line
        break
      end

      if version then
        table.insert(nodes, t(version))

        local small_version =
            string.sub(version, string.find(version, "%d+%.%d+"))
        if small_version then table.insert(nodes, t(small_version)) end
      end
    end

    return sn(nil, c(1, nodes))
  end

  ls.config.set_config {
    -- Tell LuaSnip to remember to keep around the last snippet. You can jump back into it even if you move outside of
    -- the selection.
    history = false,

    -- Update dynamic snippets as we type
    -- update_events = "TextChanged,TextChangedI",

    -- Autosnippets
    enable_autosnippets = true,

    ext_opts = {
      [types.choiceNode] = { active = { virt_text = { { "⟵ ", "Error" } } } }
    }
  }

  ls.add_snippets("all", {
    s("curdate", f(function() return os.date "%Y-%m-%d" end)),
    s("curtime", f(function() return os.date "%Y-%m-%d %H:%M:%S" end))
  })

  ls.add_snippets("nroff", {
    ls.parser.parse_snippet("dagger", "\\(dg"),
    ls.parser.parse_snippet("square", "\\(sq"),
    ls.parser.parse_snippet("half", "\\(12"),
    ls.parser.parse_snippet("quater", "\\(14"),
    ls.parser.parse_snippet("copy", "\\(co"),
    ls.parser.parse_snippet("bullet", "\\(bu"),
    ls.parser.parse_snippet("degrees", "\\(de"),
    ls.parser.parse_snippet("arrow_right", "\\(->"),
    ls.parser.parse_snippet("arrow_left", "\\(<-"),
    ls.parser.parse_snippet("arrow_up", "\\(ua"),
    ls.parser.parse_snippet("arrow_down", "\\(da"),
    ls.parser.parse_snippet("section", "\\(sc"),
    ls.parser.parse_snippet("pound", "\\(Po"),

    ls.parser.parse_snippet("alpha", "\\(*a"),
    ls.parser.parse_snippet("Alpha", "\\(*A"),
    ls.parser.parse_snippet("beta", "\\(*b"),
    ls.parser.parse_snippet("Beta", "\\(*B"),
    ls.parser.parse_snippet("gamma", "\\(*g"),
    ls.parser.parse_snippet("Gamma", "\\(*G"),
    ls.parser.parse_snippet("delta", "\\(*d"),
    ls.parser.parse_snippet("Delta", "\\(*D"),
    ls.parser.parse_snippet("epsilon", "\\(*e"),
    ls.parser.parse_snippet("Epsilon", "\\(*E"),
    ls.parser.parse_snippet("zeta", "\\(*z"),
    ls.parser.parse_snippet("Zeta", "\\(*Z"),
    ls.parser.parse_snippet("eta", "\\(*y"),
    ls.parser.parse_snippet("Eta", "\\(*Y"),
    ls.parser.parse_snippet("theta", "\\(*h"),
    ls.parser.parse_snippet("Theta", "\\(*H"),
    ls.parser.parse_snippet("iota", "\\(*i"),
    ls.parser.parse_snippet("Iota", "\\(*I"),
    ls.parser.parse_snippet("kappa", "\\(*k"),
    ls.parser.parse_snippet("Kappa", "\\(*K"),
    ls.parser.parse_snippet("lambda", "\\(*l"),
    ls.parser.parse_snippet("Lambda", "\\(*L"),
    ls.parser.parse_snippet("mu", "\\(*m"),
    ls.parser.parse_snippet("Mu", "\\(*M"),
    ls.parser.parse_snippet("nu", "\\(*n"),
    ls.parser.parse_snippet("Nu", "\\(*N"),
    ls.parser.parse_snippet("xi", "\\(*c"),
    ls.parser.parse_snippet("Xi", "\\(*c"),
    ls.parser.parse_snippet("omicron", "\\(*o"),
    ls.parser.parse_snippet("Omicron", "\\(*O"),
    ls.parser.parse_snippet("pi", "\\(*p"),
    ls.parser.parse_snippet("Pi", "\\(*P"),
    ls.parser.parse_snippet("rho", "\\(*r"),
    ls.parser.parse_snippet("Rho", "\\(*R"),
    ls.parser.parse_snippet("sigma", "\\(*s"),
    ls.parser.parse_snippet("Sigma", "\\(*S"),
    ls.parser.parse_snippet("tau", "\\(*t"),
    ls.parser.parse_snippet("Tau", "\\(*T"),
    ls.parser.parse_snippet("upsilon", "\\(*u"),
    ls.parser.parse_snippet("Upsilon", "\\(*U"),
    ls.parser.parse_snippet("phi", "\\(*f"),
    ls.parser.parse_snippet("Phi", "\\(*F"),
    ls.parser.parse_snippet("chi", "\\(*x"),
    ls.parser.parse_snippet("Chi", "\\(*X"),
    ls.parser.parse_snippet("psi", "\\(*q"),
    ls.parser.parse_snippet("Psi", "\\(*Q"),
    ls.parser.parse_snippet("omega", "\\(*w"),
    ls.parser.parse_snippet("Omega", "\\(*W"),

    ls.parser.parse_snippet("fb", "\\fB$1\\fP"),
    ls.parser.parse_snippet("fi", "\\fI$1\\fP"),
    ls.parser.parse_snippet("fc", "\\fC$1\\fP"),

    ls.parser.parse_snippet("EQ", ".EQ\n$1\n.EN"),
    ls.parser.parse_snippet("CD", ".CD\n$1\n.EN"),

    s("str", fmt("\\*[{}]", i(1))), s("reg", fmt("\\n[{}]", i(1))),

    s("DS", fmt(".DS {}\n{}\n.DE",
      { c(1, { t "B", t "C", t "I", t "L", t "R" }), i(2) }))

  })

  ls.add_snippets("lua", {
    ls.parser.parse_snippet("lf", "local $1 = function($2)\n  $0\nend"),

    s("req", fmt([[local {} = require("{}")]], {
      f(function(import_name)
        local parts = vim.split(import_name[1][1], ".", true)
        return parts[#parts] or ""
      end, { 1 }), i(1)
    }))
  })

  ls.add_snippets("rust", {
    s("modtest", fmt([[
        #[cfg(test)]
        mod tests {{
        {}

            {}
        }}
        ]], { c(1, { t "    use super::*;", t "" }), i(0) })), s("test", fmt([[
        #[test]
        fn {}(){}{{
            {}
        }}
      ]], { i(1, "testname"), rust_get_test_result(2), i(0) })),

    s("fn", fmt("fn {}({}){}{{\n    {}\n}}", {
      i(1), i(2), c(3, { sn(nil, { t " -> ", i(1), t " " }), t " " }), i(4)
    }))
  })

  ls.add_snippets("toml", {
    s("crate", fmt([[
      [package]
      name = "{}"
      version = "0.1.0"
      edition = "2021"
      description = "{}"
      publish = {}

      [dependencies]

      ]],
      {
        i(1, "cratename"), i(2, "description"), c(3, { t "true", t "false" })
      })), s("dep", fmt([[{} = {{ version = "{}" }}]], {
    i(1, "package_name"),
    d(2, function(args) return rust_cargo_get_latest_version(args[1][1]) end,
      { 1 })
  }))
  })

  vim.keymap.set({ "i", "s" }, "<c-k>", function()
    if ls.expand_or_jumpable() then ls.expand_or_jump() end
  end, { silent = true })

  vim.keymap.set({ "i", "s" }, "<c-m>",
    function() if ls.jumpable(-1) then ls.jump(-1) end end,
    { silent = true })

  vim.keymap.set({ "i", "s" }, "<c-l>", function()
    if ls.choice_active() then ls.change_choice(1) end
  end)
end

return M
