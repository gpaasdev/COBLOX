"use client";

import { useState } from "react";
import { Send, CheckCircle2 } from "lucide-react";
import { sendLiveOpsMessage } from "@/app/actions/opencloud";

export default function LiveOpsPage() {
  const [topic, setTopic] = useState("System_Alerts");
  const [message, setMessage] = useState("");
  const [loading, setLoading] = useState(false);
  const [success, setSuccess] = useState(false);

  const handleBroadcast = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!message) return;

    setLoading(true);
    setSuccess(false);

    const result = await sendLiveOpsMessage(topic, message);
    
    setLoading(false);
    if (result.success) {
      setSuccess(true);
      setMessage("");
      setTimeout(() => setSuccess(false), 3000);
    }
  };

  return (
    <div className="flex flex-col gap-6 max-w-2xl">
      <div>
        <h1 className="text-2xl font-bold tracking-tight text-slate-900">LiveOps Dispatcher</h1>
        <p className="text-slate-500">Broadcast messages to active game servers via Open Cloud.</p>
      </div>

      <div className="rounded-xl border border-slate-200 bg-white p-6 shadow-[0_2px_10px_rgb(0,0,0,0.02)]">
        <form onSubmit={handleBroadcast} className="flex flex-col gap-5">
          <div className="flex flex-col gap-1.5">
            <label htmlFor="topic" className="text-sm font-medium text-slate-700">Messaging Topic</label>
            <select
              id="topic"
              value={topic}
              onChange={(e) => setTopic(e.target.value)}
              className="rounded-lg border border-slate-200 bg-white px-3 py-2 text-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
            >
              <option value="System_Alerts">System Alerts (In-Game Banner)</option>
              <option value="Live_Event">Live Event Triggers</option>
              <option value="Maintenance">Maintenance Warnings</option>
            </select>
          </div>

          <div className="flex flex-col gap-1.5">
            <label htmlFor="message" className="text-sm font-medium text-slate-700">Message Content</label>
            <textarea
              id="message"
              rows={4}
              required
              value={message}
              onChange={(e) => setMessage(e.target.value)}
              placeholder="Enter broadcast message..."
              className="resize-none rounded-lg border border-slate-200 p-3 text-sm focus:border-blue-500 focus:outline-none focus:ring-1 focus:ring-blue-500"
            />
          </div>

          <div className="mt-2 flex items-center justify-between">
            {success ? (
              <div className="flex items-center gap-2 text-sm font-medium text-green-600">
                <CheckCircle2 className="h-4 w-4" />
                Broadcast successful!
              </div>
            ) : (
              <div /> // Spacer
            )}
            
            <button
              type="submit"
              disabled={loading || !message}
              className="inline-flex items-center gap-2 rounded-lg bg-blue-600 px-4 py-2 text-sm font-medium text-white transition-colors hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50"
            >
              <Send className="h-4 w-4" />
              {loading ? "Dispatching..." : "Send Broadcast"}
            </button>
          </div>
        </form>
      </div>
    </div>
  );
}
