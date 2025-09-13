#pragma once

#include "microui.h"
#include <stdio.h>

int mu_command_type (mu_Command* cmd) {
	return cmd->type;
}