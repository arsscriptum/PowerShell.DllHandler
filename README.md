# PowerShell.DllHandler

PowerShell Module providing easy way to get Dll exported functions information 
[VIEW DEMO](https://github.com/arsscriptum/PowerShell.DllHandler/blob/master/doc/doc.gif)

<!-- TABLE OF CONTENTS -->
## Table of Contents <!-- omit in toc -->

* [About The Project](#about-the-project)
* [Getting Started](#getting-started)
* [Usage](#usage)
* [Acknowledgements](#acknowledgements)

<!-- ABOUT THE PROJECT -->
## About The Project

[![Product Screenshot][product-screenshot]](https://github.com/arsscriptum/PowerShell.DllHandler/blob/master/doc/screenshot.png)

This utility displays the list of all exported functions and their virtual memory addresses for the specified DLL files. You can easily copy the memory address of the desired function, paste it into your debugger, and set a breakpoint for this memory address. When this function is called, the debugger will stop in the beginning of this function.
For example: If you want to break each time that a message box is going to be displayed, simply put breakpoints on the memory addresses of message-box functions: MessageBoxA, MessageBoxExA, and MessageBoxIndirectA (or MessageBoxW, MessageBoxExW, and MessageBoxIndirectW in unicode based applications) When one of the message-box functions is called, your debugger should break in the entry point of that function, and then you can look at call stack and go backward into the code that initiated this API call.

<!-- GETTING STARTED -->
## Getting Started

```pwsh
git clone https://github.com/arsscriptum/PowerShell.DllHandler/PowerShell.DllHandler.gif
pushd PowerShell.DllHandler
./Setup.ps1
```

<!-- USAGE EXAMPLES -->
## Usage


<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements

* [Nir Sofer](nirsofer@yahoo.com)
* [DLL Export Viewer](https://www.nirsoft.net/utils/dll_export_viewer.html)


Repository
----------

https://github.com/arsscriptum/PowerShell.DllHandler

