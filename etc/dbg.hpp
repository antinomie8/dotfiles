#include <cstring>
#include <iostream>
#include <iterator>
#include <ostream>
#include <string>
#include <vector>

#define id(x)                                                                            \
	std::string str = #x;                                                                  \
	std::cerr << str << " : \n";                                                           \
	for (size_t i = 0; i != str.length() + 2; ++i)                                         \
		std::cerr << "-";                                                                    \
	cerr << '\n';
#define line() std::cerr << "Line " << __LINE__ << " : ";
inline void n(uint lines = 1) {
	for (size_t i = 0; i < lines; i++)
		std::cerr << '\n';
}

// dbg_format
inline std::string dbg_format(const int& x) {
	return std::to_string(x);
}
inline std::string dbg_format(const bool& x) {
	return (x ? "true" : "false");
}
inline std::string dbg_format(const char& x) {
	std::string fmt = "'";
	fmt.push_back(x);
	fmt.push_back('\'');
	return fmt;
}
inline std::string dbg_format(const std::string& x) {
	std::string fmt = "";
	for (const char c : x) {
		if (c == '\n') {
			fmt += "\\n";
		} else {
			fmt += c;
		}
	}
	return "\"" + fmt + "\"";
}
template <typename A, typename B> inline std::string dbg_format(const std::pair<A, B>& x);
template <typename... Args> std::string dbg_format(const std::tuple<Args...>& tpl);
template <typename T>
concept Iterable = requires(T t) {
	std::begin(t);
	std::end(t);
};
template <Iterable T> inline std::string dbg_format(const T& container) {
	std::string str = "[";
	for (auto&& elt : container) {
		str += dbg_format(elt) + ", ";
	}
	if (!container.empty())
		str.pop_back(), str.pop_back();
	return str + "]";
}
template <typename T>
concept ToStringable = requires(T v) { std::to_string(v); };
template <typename T>
  requires(ToStringable<T> && !Iterable<T>)
inline std::string dbg_format(T x) {
	return std::to_string(x);
}
template <typename A, typename B>
inline std::string dbg_format(const std::pair<A, B>& x) {
	return "(" + dbg_format(x.first) + ", " + dbg_format(x.second) + ")";
}
template <typename Tuple, std::size_t Index>
void dbg_format_tuples_helper(const Tuple& tpl, std::string& result) {
	if constexpr (Index < std::tuple_size_v<Tuple>) {
		if (result != "(")
			result += ", "; // Add separator if not the first element
		result += dbg_format(std::get<Index>(tpl));
		dbg_format_tuples_helper<Tuple, Index + 1>(tpl, result);
	}
}
template <typename... Args> std::string dbg_format(const std::tuple<Args...>& tpl) {
	std::string result = "(";
	dbg_format_tuples_helper<std::tuple<Args...>, 0>(tpl, result);
	return result + ")";
}

#define dbg(...) dbg_expand(#__VA_ARGS__, __VA_ARGS__)
template <typename T> void dbg_single(const char* name, const T& val) {
	std::cerr << name << " = " << dbg_format(val) << '\n';
}
inline void dbg_expand(const char*) {} // base case for zero args
template <typename T, typename... Args>
void dbg_expand(const char* names, const T& value, const Args&... args) {
	const char* comma = strchr(names, ',');
	if (!comma) {
		dbg_single(names, value);
	} else {
		std::string name(names, comma);
		dbg_single(name.c_str(), value);

		while (*comma == ',' || *comma == ' ')
			++comma; // skip commas/spaces
		dbg_expand(comma, args...);
	}
	std::flush(std::cerr);
}

// dbg
template <typename T> void dbg_var(void) {}
template <typename T, typename... Types> void dbg_var(T& x, Types&... y) {
	std::cerr << dbg_format(x) << std::endl;
	dbg_var(y...);
}

// dbgarr
#define GET_MACRO_ARRAY(_1, _2, _3, NAME, ...) NAME
#define dbgarr(...) GET_MACRO_ARRAY(__VA_ARGS__, dbgarr3, dbgarr2, dbgarr1)(__VA_ARGS__)
#define dbgarr1(a)                                                                       \
	id(a);                                                                                 \
	for (auto x : a)                                                                       \
		std::cerr << dbg_format(x) << ", ";                                                  \
	std::cerr << '\n';
#define dbgarr2(a, n)                                                                    \
	id(a);                                                                                 \
	for (int i = 0; i < n; i++)                                                            \
		std::cerr << a[i] << " ";                                                            \
	std::cerr << '\n';
#define dbgarr3(a, n, m)                                                                 \
	id(a);                                                                                 \
	for (int i = 0; i < n; i++) {                                                          \
		for (int j = 0; j != m; ++j)                                                         \
			std::cerr << a[i * n + j] << " ";                                                  \
		std::cerr << '\n';                                                                   \
	}
