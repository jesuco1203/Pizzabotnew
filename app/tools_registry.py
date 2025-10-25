from tools.size_validation_tool import run as SizeValidationTool
from tools.user_tools import check_user_in_db, extract_and_register_name
from tools.order_tools import process_item_request, get_current_order

TOOL_REGISTRY = {
    "SizeValidationTool": SizeValidationTool,
    "check_user_in_db": check_user_in_db,
    "extract_and_register_name": extract_and_register_name,
    "process_item_request": process_item_request,
    "get_current_order": get_current_order,
}
