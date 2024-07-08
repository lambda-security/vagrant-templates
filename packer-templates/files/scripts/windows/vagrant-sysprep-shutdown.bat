@echo off
for %%i in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do (
    if exist %%i:\vagrant-sysprep.xml (
        call C:\Windows\System32\Sysprep\sysprep.exe /generalize /oobe /unattend:%%i:\vagrant-sysprep.xml /shutdown
    )
)
