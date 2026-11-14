local M = {}

function M:peek(job)
	local home = os.getenv("HOME")
	local thumbnail = home .. "/.cache/kra_preview.png"
	os.execute("unzip -p " .. job.file.url .. " mergedimage.png > " .. thumbnail)
	ya.image_show(Url(thumbnail), job.area)
end

function M:seek(job) end

return M
