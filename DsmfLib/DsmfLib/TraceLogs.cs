using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text;
using System.Threading;

namespace kuranado.moe.DSMF.DsmfLib
{
    /// <summary>
    /// <para>饥荒独立服管理器日志追踪类</para>
    /// </summary>
    public class TraceLogs
    {
        /// <summary>
        /// 用于记录消息的TraceSource类
        /// </summary>
        private TraceSource Logs { get; }


        /// <summary>
        /// <para>以指定的模块名称初始化新实例,默认过滤级别为Verbose</para>
        /// <para>模块名称将按以下格式作为源名称:</para>
        /// <para>$"{ModuleName}-{ThreadName}"</para>
        /// <para>注意:需要调用AddListener方法添加监听器,否则将不会对消息进行任何处理</para>
        /// </summary>
        /// <param name="moduleName">饥荒独立服管理器模块的名称</param>
        /// <exception cref="ArgumentNullException">模块名称为null或""时抛出异常</exception>
        public TraceLogs(string moduleName) : this(moduleName, SourceLevels.Verbose) { }


        /// <summary>
        /// <para>以指定的模块名称和过滤级别初始化新实例</para>
        /// <para>模块名称将按以下格式作为源名称:</para>
        /// <para>$"{ModuleName}-{ThreadName}"</para>
        /// <para>注意:需要调用AddListener方法添加监听器,否则将不会对消息进行任何处理</para>
        /// </summary>
        /// <param name="moduleName">饥荒独立服管理器模块的名称</param>
        /// <param name="sourceLevels">消息的过滤级别</param>
        /// <exception cref="ArgumentNullException">模块名称为null或""时抛出异常</exception>
        public TraceLogs(string moduleName,SourceLevels sourceLevels)
        {
            if (moduleName == null || moduleName == "")
                throw new ArgumentNullException("模块名称不能为空!");
            string traceName = $"{moduleName}-{Thread.CurrentThread.Name}";
            Logs = new TraceSource(traceName, sourceLevels);
            Logs.Listeners.Clear();
        }


        /// <summary>
        /// 获取或设置过滤消息等级
        /// </summary>
        public SourceLevels Filter
        {
            get => Logs.Switch.Level;
            set => Logs.Switch.Level = value;
        }


        /// <summary>
        /// 获取或设置指定监听器的过滤器
        /// </summary>
        /// <param name="index">监听器名称</param>
        /// <returns>Filter实例</returns>
        public TraceFilter this[string index]
        {
            get => Logs.Listeners[index].Filter;
            set => Logs.Listeners[index].Filter = value;
        }


        /// <summary>
        /// 添加一个TextWriterTraceListener监听器
        /// </summary>
        /// <param name="name">监听器名称</param>
        /// <param name="filePath"></param>
        /// <param name="filter"></param>
        /// <param name="traceOptions"></param>
        /// <exception cref="ArgumentNullException">当name为null或""时抛出异常</exception>
        public void AddTextListener(string name,string filePath,SourceLevels filter = SourceLevels.All,TraceOptions traceOptions = TraceOptions.None)
        {
            if (name == null || name == "")
                throw new ArgumentNullException("监听器名称不能为空!");


            Stream stream = File.Open(filePath, FileMode.OpenOrCreate, FileAccess.Write);
            stream.Seek(0, SeekOrigin.End);

            TextWriterTraceListener listener = new TextWriterTraceListener(stream);
            listener.Name = name;
            listener.Filter = new EventTypeFilter(filter);
            listener.TraceOutputOptions = traceOptions;


            Logs.Listeners.Add(listener);
        }



        /// <summary>
        /// 将指定的调试级消息传给监听器处理
        /// </summary>
        /// <param name="message">消息内容</param>
        /// <param name="id">int型消息标志码</param>
        public void Verbose(string message,int id = 0)
        {
            Logs.TraceEvent(TraceEventType.Verbose, id, $"\t{DateTime.Now} | {message}");
            Logs.Flush();
        }


        /// <summary>
        /// 将指定的信息级消息传给监听器处理
        /// </summary>
        /// <param name="message">消息内容</param>
        /// <param name="id">int型消息标志码</param>
        public void Info(string message, int id = 1)
        {
            Logs.TraceEvent(TraceEventType.Information, id, $"\t{DateTime.Now} | {message}");
            Logs.Flush();
        }


        /// <summary>
        /// 将指定的警告级消息传给监听器处理
        /// </summary>
        /// <param name="message">消息内容</param>
        /// <param name="id">int型消息标志码</param>
        public void Warning(string message,int id = 1)
        {
            Logs.TraceEvent(TraceEventType.Warning, id, $"\t{DateTime.Now} | {message}");
            Logs.Flush();
        }


        /// <summary>
        /// 将指定的错误级消息传给监听器处理
        /// </summary>
        /// <param name="message">消息内容</param>
        /// <param name="id">int型消息标志码</param>
        public void Error(string message, int id = 1)
        {
            Logs.TraceEvent(TraceEventType.Error, id, $"\t{DateTime.Now} | {message}");
            Logs.Flush();
        }


        /// <summary>
        /// 将指定的致命错误消息传给监听器处理,应当在遇到导致程序崩溃的错误时使用此方法记录
        /// </summary>
        /// <param name="message">消息内容</param>
        /// <param name="id">int型消息标志码</param>
        public void Critical(string message, int id = 1)
        {
            Logs.TraceEvent(TraceEventType.Critical, id, $"\t{DateTime.Now} | {message}");
            Logs.Flush();
        }


        /// <summary>
        /// 关闭全部监听器
        /// </summary>
        public void Close() => Logs.Close();

    }
}
