#include <SFML/Graphics.hpp>
#include <cstdlib>
#include <iostream>

int main() {
	if (std::system("brightnessctl -sd asus::kbd_backlight set 0 >/dev/null") != 0) {
		std::cerr << "Failed to disable keyboard brightness\n";
	}
	if (std::system("safeeyes -d >/dev/null") != 0) {
		std::cerr << "Failed to disable safeeyes\n";
	}

	// Get desktop video mode
	sf::VideoMode desktopMode = sf::VideoMode::getDesktopMode();

	// Create a render window in fullscreen mode
	sf::RenderWindow window(desktopMode, "Black Screen", sf::Style::None,
	                        sf::State::Fullscreen);

	// Hide mouse cursor
	window.setMouseCursorVisible(false);

	// Clear screen to black
	window.clear(sf::Color::Black);

	// Present the black framebuffer
	window.display();

	// Main loop
	while (window.isOpen()) {
		// Poll events
		while (auto event = window.pollEvent()) {
			// Close on escape or window close
			if (event->is<sf::Event::Closed>() || event->is<sf::Event::KeyPressed>()) {
				if (std::system("brightnessctl -rd asus::kbd_backlight >/dev/null") != 0) {
					std::cerr << "Failed to restore keyboard brightness\n";
				}
				if (std::system("safeeyes -e >/dev/null") != 0) {
					std::cerr << "Failed to reenable safeeyes\n";
				}
				window.close();
			}
		}
	}

	return 0;
}
